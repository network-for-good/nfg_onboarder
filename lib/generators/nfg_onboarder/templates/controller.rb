class Onboarding::<%= combined_onboarder_name %>Controller < <%= inherited_controller_name %>Controller

  # steps list
  # we do this so we can access the list of steps from outside the onboarder
  def self.step_list
  end

  def exit_without_save_steps
    []
  end

  def exit_with_save_steps
    []
  end

  # steps list
  steps *step_list

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  private

  # begin on before save steps
  # end on before save steps

  # begin on valid steps
  # end on valid steps

  def can_view_step_without_onboarding_session
    return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
    # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
    # return true if step == :get_started
    false
  end

  def get_form_target
    case step
    # catch all
    else
      OpenStruct.new(name: '')
    end
  end

  def get_onboarding_session
    # we have to find the onboarding session first from the user session, if we can't find it then we need to look at the params
    # if still can't find it then we create a new onboarding session
    onboarding_sess = nil
    onboarding_sess = ::Onboarding::Session.find_by(id: session[:onboarding_session_id]) if session[:onboarding_session_id]
    onboarding_sess ||= new_onboarding_session
    onboarding_sess.tap { |os| session[:onboarding_session_id] = os.id }
  end

  def fields_to_be_cleansed_from_form_params
    # these are fields that we don't want to store in onboarder session
    %w{}
  end

  def finish_wizard_path
     # where to take the user when the have finished this step
     # TODO add a path to where the user should go once they complete the onboarder
  end

  def new_onboarding_session
    ::Onboarding::Session.create(onboarding_session_parameters)
  end

  def onboarder_name
    "<%= onboarder_name.underscore %>_onboarder"
  end

  def onboarding_session_parameters
    {
      entity: nil,# supply the parent object to the onboarding session
      owner: onboarding_admin,
      current_step: ,  #typically the first step
      related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
      name: onboarder_name
    }
  end

  def reset_onboarding_session
    # when you need to clear the onboarding session (so the user can start a new onboarder)
    # call this method
    session[:onboarding_session_id] = nil
    session[:onboarding_import_data_import_id] = nil
  end
end
