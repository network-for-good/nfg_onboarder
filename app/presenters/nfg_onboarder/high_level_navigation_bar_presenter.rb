# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::HighLevelNavigationBarPresenter.new(onboarding_session, self)
  class HighLevelNavigationBarPresenter < NfgOnboarder::OnboarderPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(c_step, path = '')
      h.before_last_visited_point_of_no_return?(c_step) ? nil : path_with_id(c_step)
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
      return :disabled if disabled?(nav_step)
    end

    def active?(nav_step)
      nav_step.to_sym == h.controller_name.to_sym
    end

    def disabled?(nav_step)
      (all_steps.index(nav_step.to_sym) || 0) > (all_steps.index(active_step.to_sym) || 0)
    end

    def visited?(nav_step)
      model.onboarder_progress.keys.include?(nav_step.to_s)
    end

    def path_with_id(c_step)
      return nil unless model.onboarder_progress.key?(c_step.to_s)

      "/onboarding/create_campaign/#{c_step}/#{model.onboarder_progress[c_step.to_s][0]}"
    end
  end
end
