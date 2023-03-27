require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'reform/rails'

Bundler.require(*Rails.groups)
require "nfg_onboarder"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # need to capture local files in subfolders
    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    # This is a list of classes that the YAML parser is allowed to deserialize
    config.active_record.yaml_column_permitted_classes = [
      Date,
      Time,
      DateTime,
      Set,
      OpenStruct,
      Symbol,
      ActionDispatch::Http::UploadedFile
    ]
  end
end

