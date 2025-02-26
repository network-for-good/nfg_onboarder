require_relative "boot"
#require File.expand_path('../boot', __FILE__)

require "rails/all"
require 'reform/rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "nfg_onboarder"

module Dummy
  class Application < Rails::Application
    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.active_record.use_yaml_unsafe_load = true
    # config.active_record.yaml_column_permitted_classes = [Symbol, Date]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
