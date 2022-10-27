require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'factory_bot_rails'
require 'shoulda/matchers'

Rails.backtrace_cleaner.remove_silencers!
ActiveRecord::Migrator.migrations_paths = 'spec/dummy/db/migrate'

#
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
# load factories to avoid 'Factory not registered' error in development
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f } if Rails.env.development?

# by default, FactoryBot will look for factories in the Dummy app, but
# we want to have them in the /spec/factories folder
# but, when running on cicleci, the `find_definitions` line below raises
# an error that the definitions are already loaded. 
FactoryBot.definition_file_paths << "#{File.dirname(__FILE__)}/factories"
FactoryBot.find_definitions rescue nil

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
