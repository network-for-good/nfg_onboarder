# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::OnboarderNavigationBarPresenter.new(onboarding_session, self)
  class OnboarderNavigationBarPresenter < NfgOnboarder::OnboarderPresenter
    def points_of_no_return
      @points_of_no_return ||= h.controller.send(:points_of_no_return)
    end

    def render_previous_button_unless?
      on_first_step? or h.controller.single_use_steps.include?(h.controller.previous_step) or h.at_point_of_no_return?
    end

    # Returns a check mark for the last step's icon
    def step_icon(nav_step)
      nav_step == all_steps.last ? 'check' : nil
    end

    # Returns an nfg_ui friendly status for the :step component's status trait
    #
    # Example usage:
    # = ui.nfg :step, onboarder_presenter.step_status(the_step), step: 1, href: wizard_path(the_step)
    def step_status(nav_step)
      return :active if active?(nav_step)
      return :visited if visited?(nav_step)
      # in case steps change, if the step or active step can't be found in what
      # is currently the list of steps  don't barf
      return :disabled if disabled?(nav_step)
    end
  end
end
