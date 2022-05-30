# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::NavigationBarPresenter.new(onboarding_session, self)
  class NavigationBarPresenter < NfgOnboarder::OnboarderPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(step, path: '')
      h.before_last_visited_point_of_no_return?(step) ? nil : path
    end

    def points_of_no_return
      @points_of_no_return ||= h.controller.send(:points_of_no_return)
    end

    def render_previous_button_unless?
      on_first_step? or h.controller.single_use_steps.include?(h.controller.previous_step) or h.at_point_of_no_return?
    end

    # Provide a custom locale lookup
    # for the step nav body text
    # or default to humanizing the
    # step's symbol.
    def step_body(step)
      I18n.t(step, scope: h.locale_namespace + [:step_navigations], default: step.to_s.humanize)
    end

    # Returns a check mark for the last step's icon
    def step_icon(step)
      step == all_steps.last ? 'check' : nil
    end

    # Returns an nfg_ui friendly status for the :step component's status trait
    #
    # Example usage:
    # = ui.nfg :step, onboarder_presenter.step_status(the_step), step: 1, href: wizard_path(the_step)
    def step_status(step)
      return :active if step.to_sym == active_step.to_sym
      return :visited if try(:completed_steps, h.controller_name).try(:include?, step)
      # in case steps change, if the step or active step can't be found in what
      # is currently the list of steps  don't barf
      return :disabled if (all_steps.index(step.to_sym) || 0) > (all_steps.index(active_step.to_sym) || 0)
    end
  end
end
