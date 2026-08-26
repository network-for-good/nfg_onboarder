source 'https://rubygems.org'

# Declare your gem's dependencies in nfg_onboarder.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Security floors for SCA root causes (NFG-3931). Each entry is the gem the CVE
# actually lives in, not the direct parent Snyk attributed it to. Pinned here so a
# future `bundle update` cannot silently regress the lockfile below the fix.
gem 'rails', '~> 7.2.0', '>= 7.2.3.2' # CVE-2025-24293, CVE-2026-33195, CVE-2026-66066: activestorage/activesupport
gem 'bundler', '~> 2.5'
gem 'sprockets', "~> 3.7"
gem "nokogiri", ">= 1.19.4"           # was pinned to 1.18.9; CVE-2026-57234, CVE-2026-57438 (+ NFG-4294 overlap)
gem 'rack', '>= 2.2.23'               # NFG-4294 overlap
gem 'thor', '>= 1.4.0'                # NFG-4294 overlap
gem 'net-imap', '>= 0.6.5'            # CVE-2026-42246, CVE-2026-42256, CVE-2026-42257, CVE-2026-47240
gem 'websocket-driver', '>= 0.8.2'    # CVE-2026-61666

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

