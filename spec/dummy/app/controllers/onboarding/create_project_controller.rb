class Onboarding::CreateProjectController < NfgOnboarder::BaseController
  # steps list
  steps :project_name, :project_description

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  private

  def get_onboarding_admin
    defined?(current_admin) ? current_admin : OpenStruct.new(id: 999, first_name: 'Any', last_name: 'User', email: 'any@user.com', primary_key: 'id')
  end

  # on before save steps
  def project_description_on_before_save
    # you can add logic here to perform, such as appending data to the params, before the form is to be saved
  end

  def project_name_on_before_save
    # you can add logic here to perform, such as appending data to the params, before the form is to be saved
  end

  def exit_without_save_steps
    [:project_name]
  end

  # on valid steps
  def project_description_on_valid_step
    onboarding_session.update(completed_at: Time.now)
  end

  def project_name_on_valid_step
p "in project_name_on_valid_step"
    # since we had supplied the form with a new project record
    # we need to now ensure that the project record id is
    # stored to the cookie, and all of the related
    # onboarding session relationship are updated.
    @project = form.model
    cookies[:project_id] = @project.id
    onboarding_session.owner = project # typically, this would be a user, but here project and user are the same thing
    onboarding_session.entity = project # typcially, this would be a tenant (i.e. site, or entity), but we don't have that concept here
    onboarding_session.save!
    session[:onboarding_session_id] = onboarding_session.id
  end

  def can_view_step_without_onboarding_session
    return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
    # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
    return true if step.to_sym == :project_name

    false
  end

  def get_form_target
    case step
    when :project_name
      project || Project.new
    when :project_description
      project
    end
  end

  def finish_wizard_path
     # where to take the user when the have finished this step
     "https://www.google.com"
  end

  def onboarder_name
    "create_project"
  end

  def project
    @project ||= Project.find_by(id: cookies[:project_id]) if cookies[:project_id].present?
  end

  def get_onboarding_session
    # we have to find the onboarding session first from the user session, if we can't find it then we need to look at the params
    # if still can't find it then we create a new onboarding session
    onboarding_sess = nil
    onboarding_sess = ::Onboarding::Session.find_by(id: session[:onboarding_session_id]) if session[:onboarding_session_id]
    onboarding_sess ||= new_onboarding_session
    onboarding_sess.tap { |os| session[:onboarding_session_id] = os.id }
  end

  def new_onboarding_session
    ::Onboarding::Session.new(onboarding_session_parameters)
  end

  def onboarding_session_parameters
    # raise "here we are"
    {
      entity: project,# supply the parent object to the onboarding session
      owner: project,
      current_step: "project_name",  #typically the first step
      related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
      name: onboarder_name
    }
  end
end
