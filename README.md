# NfgOnboarder

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nfg_onboarder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nfg_onboarder

## Usage

Run the installer
```ruby
rails g nfg_onboarder:install
```

This should create the following files
```ruby
      create  db/migrate/20170605133220_create_onboarding_session.rb
      create  db/migrate/20170605133221_create_onboarding_related_object.rb
      create  app/models/onboarding/session.rb
      create  app/models/onboarding/related_object.rb
      create  app/controllers/onboarding/base_controller.rb
      insert  app/models/admin.rb
```

Then migrate the db

An association between the onboarding_sessions parent object (typically at the tenant level for a multi-tenant site) and the onboarding session needs to be created
Likely, you will add to the parent object the following

```ruby
has_many :onboarding_sessions, foreign_key: "entity_id", class_name: "Onboarding::Session"
```

Include the NfgOnboarding::OnboardableObject module on any object that will be built with the onboarder
```ruby
include NfgOnboarder::OnboardableObject
```

Add a namespacing to the routes file for onboarding
```ruby
  namespace :onboarding do

  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Versioning

The gem version (`lib/nfg_onboarder/version.rb`) tracks the **Rails major.minor series it supports**; the **patch segment belongs to the gem itself**. So `7.2.x` means "the x-th release in the Rails 7.2 series" — a gem-only bug fix bumps the patch (e.g. `7.2.4` → `7.2.5`) and does **not** imply a matching Rails patch version. Actual Rails compatibility is enforced by the `rails` dependency constraint in `nfg_onboarder.gemspec`, not by the version number.

- Rails major/minor upgrade (e.g. Rails 7.2 → 8.0): gem goes to `8.0.0`.
- Gem-only fix or feature, no Rails change: bump the patch segment only.
- Pre-releases for UAT: append a prerelease suffix, e.g. `7.2.4.uat1`. RubyGems treats any lettered segment as a prerelease (it sorts *below* the final version and is never picked up by `~>` constraints), so host apps must pin it explicitly: `gem 'nfg_onboarder', '7.2.4.uat1'`. Published versions are immutable — each UAT iteration needs a new suffix (`uat2`, `uat3`, ...), and the final release drops the suffix.

Note: this policy is not fully semver — a breaking change to the gem's own API (generators, controller helper contract) can't be signaled independently of the Rails series, so call out breaking changes prominently in `CHANGELOG.md`.

Historical exception: `7.2.3.1` mirrored the full Rails patch version (`7.2.3.1`) during a security upgrade; releases after it follow the policy above.

## Releasing

To release a new version:

1. Update the version number in `lib/nfg_onboarder/version.rb` (see Versioning above).
2. Add an entry to `CHANGELOG.md`.
3. Run `bin/publish_gem`, which builds the gem into `pkg/` and pushes it to the [network-for-good GitHub Packages registry](https://rubygems.pkg.github.com/network-for-good) (requires a `:github` key in `~/.gem/credentials` with a token that has the `write:packages` scope).
4. Tag the release: `git tag v<version> && git push --tags`.
