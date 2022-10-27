module NfgOnboarder
  class Engine < ::Rails::Engine
    config.factory_bot.definition_file_paths +=
      [File.expand_path('../factories', __FILE__)] if defined?(FactoryBotRails)
  end
end
