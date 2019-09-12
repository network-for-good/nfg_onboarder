require "nfg_onboarder/engine"
require 'nfg_onboarder/onboarding_controller_helper'
require "reform"
require 'wicked'
require 'decent_exposure'
require 'nfg_ui'
require 'simple_form'

module NfgOnboarder

  # The router NfgOnboarder should use to generate routes. Defaults
  # to :main_app. Should be overridden by engines in order
  # to provide custom routes when the onboarder is embedded
  # in another mountable engine
  mattr_accessor :router_name
  @@router_name = nil

  # used to setup configurations
  # Only needed if the Onboarder is being embedded in
  # another mountable engine and will need that
  # engines routes
  # Set the above on setting the router_name
  def self.setup
    yield self
  end

  # returns the name of the engine/app
  # from which to generate onboarder routes
  def self.available_router_name
    router_name || :main_app
  end
end
