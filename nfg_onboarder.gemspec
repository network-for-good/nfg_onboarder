# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nfg_onboarder/version'

Gem::Specification.new do |spec|
  spec.name          = "nfg_onboarder"
  spec.version       = NfgOnboarder::VERSION
  spec.authors       = ["Thomas Hoen"]
  spec.email         = ["tom@givecorps.om"]

  spec.summary       = %q{Provides the framework and generators for the Reform/WickedWizard onboarders}
  spec.description   = %q{Provides the framework and generators for the Reform/WickedWizard onboarders}
  spec.homepage      = "https://github.com/network-for-good/nfg_onboarder"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency "factory_girl_rails"
  spec.add_development_dependency "shoulda-matchers"


  spec.add_dependency 'rails', '~> 4.2.7'
  spec.add_dependency 'reform', '~> 1.2'
  spec.add_dependency 'wicked', '~> 1.1'
  spec.add_dependency 'decent_exposure', '~> 2.3'
  spec.add_dependency 'haml'

end
