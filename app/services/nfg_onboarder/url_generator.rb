class NfgOnboarder::UrlGenerator
  include Rails.application.routes.url_helpers

  attr_reader :onboarding_session

  def initialize(onboarding_session)
    @onboarding_session = onboarding_session
  end

  def call
    onboarding_jump_to_last_visited_step_url
  end

  private
  def onboarding_jump_to_last_visited_step_url
    url_for(
      controller: onboarding_session.current_completed_step_array.join('/'),
      id: onboarding_session.current_step,
      only_path: true,
      action: 'show'
      )
  end

end