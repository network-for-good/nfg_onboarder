class Onboarding::<%= combined_onboarder_name %>Controller < <%= inherited_controller_name %>Controller

  # steps list

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  private

  # on before save steps

  # on valid steps

  def can_view_step_without_onboarding_session
    return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
    # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
    # return true if step == :get_started
    false
  end

  def get_form_target
    case step
    else
      OpenStruct.new(name: '')
    end
  end

  def finish_wizard_path
     # where to take the user when the have finished this step
     # TODO add a path to where the user should go once they complete the onboarder
  end

  def onboarder_name
    "<%= onboarder_name.underscore %>"
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
      current_step: ,  #typically the first step
      related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
      name: onboarder_name
    }
  end
end