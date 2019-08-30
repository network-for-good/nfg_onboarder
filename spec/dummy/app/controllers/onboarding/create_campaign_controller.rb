class Onboarding::CreateCampaignController < NfgOnboarder::BaseController

  expose(:onboarding_group_steps) {[]} #add symbol for each sub onboarder

  private

  def get_onboarding_admin
    defined?(current_admin) ? current_admin : OpenStruct.new(id: 999, first_name: 'Any', last_name: 'User', email: 'any@user.com', primary_key: 'id')
  end

  def finish_wizard_path

  end
end