# frozen_string_literal: true

module NfgOnboarder
  class UrlGenerator
    attr_reader :onboarding_session, :context

    def initialize(onboarding_session, context)
      @onboarding_session = onboarding_session
      @context = context
    end

    def call
      onboarding_jump_to_last_visited_step_url
    end

    private

    def onboarding_jump_to_last_visited_step_url
      # First we attempt to create the url using the url helpers
      # of the main application
      Rails.application.routes.url_helpers.url_for(
        controller: onboarding_session.current_completed_step_array.join('/'),
        id: onboarding_session.current_step,
        only_path: true,
        action: 'show'
      )
    rescue StandardError
      # if the above doesn't work, we attempt to create url from either the
      # main_app or the including engine (like nfg_csv_importer) since the above
      # call would have failed because the main application does not know about
      # the controller/routes that are included in the engine.
      _context.url_for(
        controller: onboarding_session.current_completed_step_array.join('/'),
        id: onboarding_session.current_step,
        only_path: true,
        action: 'show'
      )
    end

    def _context
      context.send(NfgOnboarder.available_router_name)
    end
  end
end
