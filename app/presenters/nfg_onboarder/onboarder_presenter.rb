
# Ex: NfgCsvImporter::OnboarderPresenter.new(onboarding_session)
module NfgOnboarder
  class OnboarderPresenter < NfgOnboarder::GemPresenter
    def active_step
      # this is the step that is currently being displayed.
      # This may be different from the onboarding_session.current_step, which is the last
      # step submitted.
      h.params[:id]
    end

    # Detects whether you're currently on the first step in the session
    # or, literally on the first step via clicking the back button
    #
    # Used for supporting whether or not to show things on the
    # first step (e.g.: the steps nav)
    def on_first_step?
      h.first_step
    end

    def first_step
      all_steps.first
    end

    # returns an array of symbols: [:step1, :step2, :step3]
    def all_steps
      @all_steps ||= navigation_steps
    end

    def steps_type
      h.controller.onboarding_group_steps.present? ? :onboarding_group_steps : :wizard_steps
    end

    def navigation_steps
      return h.controller.onboarding_group_steps if steps_type == :onboarding_group_steps

      h.controller.wizard_steps
    end
  end
end