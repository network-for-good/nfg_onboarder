class Onboarding::<%= combined_onboarder_name %>Controller < <%= inherited_controller_name %>Controller

  # steps list

  private

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
  end

  def onboarder_name
    "<%= onboarder_name.underscore %>"
  end
end