# Changelog

All notable changes to this gem are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project uses the version declared in `lib/nfg_onboarder/version.rb`. Versioning policy: the version tracks the Rails major.minor series the gem supports, while the patch segment is the gem's own release counter — see the Versioning section in the README. Note: between `0.0.3` (2018) and `7.2.0` (2025) the gem's version was not bumped even though it went through the `rails_5`, `rails_6`, `rails_6_1`, and `rails_7_2` upgrade branches — those releases predate changelog tracking and are not itemized below.

## [7.2.3.1.uat4] - 2026-08-12
### Fixed
- Changed the fallback coder in `NfgOnboarder::Session` (used when a host app hasn't set `Rails.application.config.default_coder`) from `JSON` to `YAML`. Step-tracking throughout the gem (and consumers like `nfg_csv_importer`) reads `step_data`/`onboarder_progress` back with Symbol keys and Symbol array members (e.g. `onboarder_progress[controller_name] << step`, where `step` is a Symbol). `JSON` round-trips those as Strings, so on a host app that never configured `default_coder`, the wizard silently loses track of completed/visited steps after the first DB reload, causing `Wicked::Wizard::InvalidStepError` mid-onboarding. `YAML` preserves Symbols across dump/load, matching what every real consumer already sets explicitly — this just makes the safe default match established practice instead of silently miscompiling wizard state.

## [7.2.3.1.uat3] - 2026-08-10
### Fixed
- Guarded `Rails.application.config.default_coder` lookups in `NfgOnboarder::Session` with `try` so host apps that haven't defined `default_coder` on their app config don't raise a `NoMethodError` on boot.

## [7.2.3.1.uat2] - 2026-07-31
### Fixed
- Added `github_repo` metadata to the gemspec so published packages are linked to this repository and inherit its permissions. The unlinked `7.2.3.1.uat1` package was invisible to CI tokens, causing `bundle install` in consuming apps' CI to fail with "that version can no longer be found in that source".

## [7.2.3.1.uat1] - 2026-07-13
### Changed
- Upgraded Rails from `7.2.2.1` to `7.2.3.1` (patch release; resolves several Rails CVEs, including a critical Active Storage advisory and a high-severity Active Storage path traversal advisory both patched at `7.2.3.1`/`7.2.2.2`).

### Removed
- Removed unused gem dependencies from `nfg_onboarder.gemspec`: `execjs`, `puma`, `byebug`, `bigdecimal`. None were referenced anywhere in the codebase; the app boots and the full spec suite passes without them. Removing `puma` also eliminates 5 open Dependabot alerts against it (including one critical).

### Added
- Added `CLAUDE.md` documenting the engine's architecture (Reform/Wicked wizard flow, Session/RelatedObject domain model, generators, view conventions) for contributors.

## [7.2.1] - 2025-05-08
- Gem version bump.

## [7.2.0] - 2025-05-08
- Upgraded to Rails 7.2 and Ruby 3.3.7.
- Bumped `nfg_ui` to match.

## [0.0.3] - 2018-10-03
- Bumped the `decent_exposure` dependency version.

## [0.0.2] - 2018-05-21
- Gem version bump.

## [0.0.1] - 2017-06-01
- Initial gem structure.
