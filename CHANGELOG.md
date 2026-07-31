# Changelog

All notable changes to this gem are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project uses the version declared in `lib/nfg_onboarder/version.rb`. Versioning policy: the version tracks the Rails major.minor series the gem supports, while the patch segment is the gem's own release counter — see the Versioning section in the README. Note: between `0.0.3` (2018) and `7.2.0` (2025) the gem's version was not bumped even though it went through the `rails_5`, `rails_6`, `rails_6_1`, and `rails_7_2` upgrade branches — those releases predate changelog tracking and are not itemized below.

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
