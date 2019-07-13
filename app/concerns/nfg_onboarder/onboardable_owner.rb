module NfgOnboarder::OnboardableOwner
  extend ActiveSupport::Concern

  included do
    has_many :onboarding_sessions, as: :owner, class_name: "Onboarding::Session", dependent: :destroy
  end

  # The import data controller in nfg_csv_importer sets the name as 'import_data'.
  # Therefore we need to pass in a name in order to find the correct onboarding_session

  def onboarding_session(name: default_onboarder)
    # we assume that each containing object has a default onboarder for their activity
    onboarding_session_for(name)
  end

  def onboarding_session_for(name)
    onboarding_sessions.where(completed_at: nil, name: name).order('created_at DESC').limit(1).first
  end

  def current_step
    onboarding_session.current_step
  end

  def completed_steps
    onboarding_session.completed_steps
  end

  def default_onboarder
    # can be overridden in the containing object
    self.class.to_s.underscore + "_onboarder"
  end
end
