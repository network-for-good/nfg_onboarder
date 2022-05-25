# frozen_string_literal: true

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'factory_bot_rails'
require 'shoulda/matchers'

Rails.backtrace_cleaner.remove_silencers!
ActiveRecord::Migrator.migrations_paths = 'spec/dummy/db/migrate'

#
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Capybara.register_driver :selenium do |app|
  # profile = Selenium::WebDriver::Firefox::Profile.new
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.order = "random"
  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
end

# this fails when run locally (at least for me TDH)
# appears to be needed at Solano
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# By default, FactoryBot searches the dummy app in spec/dummy for FactoryBot factories
FactoryBot.definition_file_paths = [File.expand_path("#{__dir__}/factories")]
FactoryBot.find_definitions
