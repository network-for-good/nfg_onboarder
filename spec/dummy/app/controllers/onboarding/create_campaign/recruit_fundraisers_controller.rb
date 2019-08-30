class Onboarding::CreateCampaign::RecruitFundraisersController < Onboarding::CreateCampaignController

  # steps list
  steps :initial_setup, :build_page

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  private

  # on before save steps
  def build_page_on_before_save
    # you can add logic here to perform, such as appending data to the params, before the form is to be saved
  end

  def initial_setup_on_before_save
    # you can add logic here to perform, such as appending data to the params, before the form is to be saved
  end


  # on valid steps
  def build_page_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def initial_setup_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end


  def can_view_step_without_onboarding_session
    return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
    # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
    # return true if step == :get_started
    false
  end

  def get_form_target
    case step
        when :initial_setup
          OpenStruct.new(name: '') # replace with your object that the step will update
        when :build_page
          OpenStruct.new(name: '') # replace with your object that the step will update
    else
      OpenStruct.new(name: '')
    end
  end

  def finish_wizard_path
     # where to take the user when the have finished this step
     # TODO add a path to where the user should go once they complete the onboarder
  end

  def onboarder_name
    "recruit_fundraisers"
  end

  def get_onboarding_session
    # Use the following as an example of how an onboarding session would be either retrieved or instantiated
    # We call new rather than create because we don't want the onboarding session
    # to be saved if the user does not continue past the first step.
    # onboarding_admin.onboarding_session_for(onboarder_name) || Onboarding::Session.new(onboarding_session_parameters)
  end

  def onboarding_session_parameters
    {
      entity: nil,# supply the parent object to the onboarding session
      user: onboarding_admin,
      current_step: 'initial_setup',  #typically the first step
      related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
      name: onboarder_name
    }
  end
end