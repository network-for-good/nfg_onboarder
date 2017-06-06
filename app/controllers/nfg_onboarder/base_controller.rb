class NfgOnboarder::BaseController < ActionController::Base
  include Wicked::Wizard
  helper NfgOnboarder::ApplicationHelper

  require 'nfg_onboarder/onboarding_controller_helper'
  include NfgOnboarder::OnboardingControllerHelper

end
