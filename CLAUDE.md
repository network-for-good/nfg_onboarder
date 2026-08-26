# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`nfg_onboarder` is a Rails **engine gem** (not a standalone app) that provides a framework and generators for building multi-step "onboarder" wizards on top of **Reform** (form objects) and **Wicked** (step-machine controller mixin). Consuming host apps add the gem, run its generators, and get a wizard controller/form/view/session scaffold per onboarder flow. `spec/dummy` is a minimal Rails app that exists purely to exercise the engine and doubles as a worked example of what a host app is expected to build.

## Commands

```bash
bin/setup                 # bundle install
bundle exec rspec         # run the full suite (also just `rake` / `rake spec` — Rakefile default task)
bundle exec rspec spec/models/nfg_onboarder/session_spec.rb        # single file
bundle exec rspec spec/models/nfg_onboarder/session_spec.rb:42     # single example by line
bin/console                # interactive console loaded against spec/dummy
```

Feature specs (`spec/features/*`) drive a real Capybara + Selenium/Chrome session, so `chromedriver` must be on `PATH` locally (CI installs it via the `browser-tools` CircleCI orb) — expect those specs to fail locally without it; that's an environment gap, not a regression.

The dummy app's DB (`spec/dummy/db`) needs to exist for specs to run: `cd spec/dummy && bundle exec rake db:create db:schema:load` (mirrors what CI does in `.circleci/config.yml`).

Generators can be exercised against the dummy app for manual testing, e.g. from `spec/dummy`: `bundle exec rails g nfg_onboarder:onboarder OnboarderName step1 step2`.

## Architecture

### Engine wiring
`lib/nfg_onboarder.rb` requires `reform`, `wicked`, `decent_exposure`, `nfg_ui`, and `simple_form` — adding this gem to a host Gemfile transitively pulls in that whole stack. `lib/nfg_onboarder/engine.rb` is a near-empty `Rails::Engine` (just wires FactoryBot definition paths); routes/views/initializers are auto-mounted per normal Rails engine conventions. `NfgOnboarder.setup { |c| c.router_name = ... }` / `NfgOnboarder.available_router_name` (defaults to `:main_app`) exists so an *intermediate* engine embedding this gem can tell `NfgOnboarder::UrlGenerator` which route-helper proxy to use — routing is not auto-mounted, host apps declare their own `namespace :onboarding do end`.

### Domain model — Session / RelatedObject / entity / owner
- `app/models/nfg_onboarder/session.rb` (table `onboarding_sessions`): `belongs_to :owner, polymorphic: true` (the actor driving onboarding, e.g. Admin), `belongs_to :entity` (the tenant/parent scoping object), `has_many :related_objects`. All wizard state (`step_data`, `onboarder_progress`, `completed_high_level_steps`) is serialized via `Rails.application.config.default_coder`, configured by the host app. `method_missing` lets `session.project` fetch the related object named `"project"` directly.
- `app/models/nfg_onboarder/related_object.rb` (table `onboarding_related_objects`): polymorphic join (`belongs_to :target, polymorphic: true`) between a session and the arbitrary domain objects (Project, Fundraiser, ...) being assembled step by step, addressed by symbolic `name`. `after_destroy` cascades to destroy the parent session.
- `app/concerns/nfg_onboarder/onboardable_object.rb` / `onboardable_owner.rb` — mixins for host-app models. Note: these concerns hardcode a reference to `Onboarding::RelatedObject` (not `NfgOnboarder::RelatedObject`) — they assume the host app has run the `install` generator, which creates that subclass. This coupling is a real constraint when changing generator output.

So: `entity` = tenant scope, `owner` = polymorphic actor, `related_objects` = polymorphic, name-addressed collection of in-progress domain records.

### Wizard flow (Wicked + Reform + Session state)
`NfgOnboarder::BaseController` is a thin shell: `include Wicked::Wizard`, `include NfgOnboarder::OnboardingControllerHelper`. **Nearly all framework behavior lives in `lib/nfg_onboarder/onboarding_controller_helper.rb`**, mixed in via an `included do ... end` block that runs `layout`/`before_action`/`expose` class macros in the including controller's context — read this file first when touching wizard behavior.

- Each step name maps by convention to a Reform form class: `get_form_object_name` builds `"::#{ControllerName minus 'Controller'}::#{step.camelize}Form"`. Steps without a form use `NfgOnboarder::InformationalForm` as a no-op placeholder.
- Per-step state is persisted onto the `Session` record, not the wizard params: `update_onboarding_session_step_data` stashes cleansed raw params per controller+step; `update_onboarding_session_progress` appends to `onboarder_progress`; `process_on_last_step` marks `completed_high_level_steps`.
- Optional per-step hooks a host controller can define and get called reflectively (via `respond_to?`/`send`): `#{step}_on_before_save`, `#{step}_on_valid_step`, `#{step}_on_invalid_step`, `#{step}_on_before_show`.
- Multi-level ("group") wizards: a group controller exposes `onboarding_group_steps` (sub-onboarder names) while each sub-onboarder controller has its own `steps`; presenter classes (`app/presenters/nfg_onboarder/`) distinguish `:wizard_steps` vs `:onboarding_group_steps` via a `SimpleDelegator`-based chain (`GemPresenter` → `OnboarderPresenter`/`OnboarderNavigationBarPresenter` → `WizardStepsNavigationBarPresenter`/`GroupStepsNavigationBarPresenter`).
- Recaptcha is a pure hook point, not wired in: `expose(:use_recaptcha?) { false }` defaults off; a host controller overrides it per-step. The gem does not depend on or configure the `recaptcha` gem itself.

### Methods a host controller MUST override
(these raise or return unusable defaults in the base — check `onboarding_controller_helper.rb` before assuming a default): `self.step_list`, `get_onboarding_session`, `onboarder_name`, `get_form_target`, `finish_wizard_path`, `get_onboarding_admin`. Optional overrides: `exit_without_save_steps`, `single_use_steps`, `points_of_no_return`, `can_view_step_without_onboarding_session`, `use_recaptcha?`, `fields_to_be_cleansed_from_form_params`.

### Generators (`lib/generators/nfg_onboarder/`)
- `install` — one-time bootstrap: copies the two core migrations, creates host-app `Onboarding::Session < NfgOnboarder::Session`, `Onboarding::RelatedObject < NfgOnboarder::RelatedObject`, `Onboarding::BaseController < NfgOnboarder::BaseController`, and injects `include NfgOnboarder::OnboardableOwner` into `app/models/admin.rb` (assumes an `Admin` model already exists). Host app still must manually wire the tenant association, `OnboardableObject` includes, and the `namespace :onboarding` route block (see README).
- `onboarder` — scaffolds one concrete flow: `rails g nfg_onboarder:onboarder OnboarderName[::GroupName] step1 step2 ...`, generating the controller (pre-wired `step_list`/hook stubs), one Reform form per step, one haml view per step (rendered through `onboarding/sub_layout`), locale YAML, and route injection.

### Views
Two parallel Haml view sets exist side by side: a legacy Bootstrap-panel set (`onboarding/_*`) and a newer `onboarding/nfg_ui/_*` set built on the internal `nfg_ui` component DSL (`ui.nfg :component`) with `simple_form_for`. Both expose a `_sub_layout` partial that step views render through, yielding the form builder into the step's own content — check which set a given onboarder uses before adding shared markup changes.

### Testing
`spec/rails_helper.rb` boots `spec/dummy/config/environment.rb` — the dummy app *is* the test fixture; `spec/dummy/app/controllers/onboarding/create_project_controller.rb` and its forms are the canonical worked example of implementing an onboarder. `ActiveRecord::Migrator.migrations_paths` is pointed at `spec/dummy/db/migrate`. `spec/dummy/Rakefile` is leftover Rails scaffolding and unrelated to running this gem's specs — always use the top-level `Rakefile`/`bundle exec rspec`.
