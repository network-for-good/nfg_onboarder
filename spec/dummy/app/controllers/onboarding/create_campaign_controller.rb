class Onboarding::CreateCampaignController < Onboarding::BaseController

  expose(:onboarding_group_steps) {[]} #add symbol for each sub onboarder

  private

  def finish_wizard_path

  end
end