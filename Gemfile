source 'https://rubygems.org'

# Declare your gem's dependencies in nfg_onboarder.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Security floors for SCA root causes (NFG-4294). Each entry is the gem the CVE
# actually lives in, not the direct parent Snyk attributed it to. Pinned here so a
# future `bundle update` cannot silently regress the lockfile below the fix.
gem 'rails', '~> 7.2.0', '>= 7.2.3.2' # CVE-2026-33176: activesupport
gem 'bundler', '~> 2.5'
gem 'sprockets', "~> 3.7"
gem "nokogiri", ">= 1.19.4"           # was pinned to 1.18.9; CVE-2025-49795, CVE-2025-49796, CVE-2025-6021, CVE-2026-57438
gem 'rack', '>= 2.2.23'               # CVE-2025-59830, CVE-2025-61770/71/72/919, CVE-2026-34230/785/826/829/830
gem 'thor', '>= 1.4.0'                # CVE-2025-54314 (disputed upstream; bump is free)

# Compatibility ceiling, unrelated to the security floors above: selenium-webdriver
# has no upper bound in the gemspec, so unconstrained resolution picks up a
# breaking major version that Capybara 3.35 (also unbounded) doesn't support:
# - selenium-webdriver 4.x changed Selenium::WebDriver::Logger#initialize's
#   signature, which Capybara 3.35's selenium driver still calls the old way
#   (wrong number of arguments (given 2, expected 0..1)).
# Cap below the breaking major version until Capybara is upgraded past this
# incompatibility.
# (puma was previously pinned here but is unused: the test suite runs against
# webrick via `Capybara.server = :webrick` in spec/rails_helper.rb and the
# gemspec treats puma as intentionally not a dependency, so it was removed to
# clear CVE-2026-47736 / CVE-2026-47737.)
gem 'selenium-webdriver', '< 4'

group :test do
  gem 'reform-rails', '~> 0.2.3'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

