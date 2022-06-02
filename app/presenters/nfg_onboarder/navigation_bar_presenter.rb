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
    def step_status(nav_step)
      return :active if active?(nav_step)
      return :visited if visited?(nav_step)
      # in case steps change, if the step or active step can't be found in what
      # is currently the list of steps  don't barf
      return :disabled if disabled?(nav_step)
    end

    # returns the active trait if current_step is active
    def breadcrumb_status(nav_step)
      return :active if active?(nav_step)

      nil
    end

    # returns disabled along with muted class for the href if passed step not visited yet
    def href_class(nav_step)
      return 'text-muted disabled' unless visited?(nav_step) || active?(nav_step)

      nil
    end

    def active?(nav_step)
      nav_step.to_sym == active_step.to_sym
    end

    def visited?(nav_step)
      try(:completed_steps, h.controller_name).try(:include?, nav_step)
    end

    def disabled?(nav_step)
      (all_steps.index(nav_step.to_sym) || 0) > (all_steps.index(active_step.to_sym) || 0)
    end
  end
end