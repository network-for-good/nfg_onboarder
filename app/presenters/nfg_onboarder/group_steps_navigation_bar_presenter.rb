# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::GroupStepsNavigationBarPresenter.new(onboarding_session, self)
  class GroupStepsNavigationBarPresenter < NfgOnboarder::OnboarderPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(nav_step, path = '')
      h.before_last_visited_point_of_no_return?(nav_step) ? nil : path_with_id(nav_step)
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
    def step_body(nav_step)
      I18n.t(
        nav_step,
        scope: h.locale_namespace + [:step_navigations],
        default: nav_step.to_s.titleize
      )
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
      return :disabled if disabled?(nav_step)
    end

    # Checks whether the step is active or not. If the step is active, it will return true.
    def active?(nav_step)
      nav_step.to_sym == h.controller_name.to_sym
    end

    def disabled?(nav_step)
      !visited?(nav_step) && !active?(nav_step)
    end

    # Checks whether the step is visited or not. If the step is visited, it will return true.
    # Since the onboarder_progress is a hash, the key is the step name and the value is an array
    # of the steps that have been visited. so here we check if the step is visited or not by checking
    # if the step name is in the onboarder_progress hash.
    def visited?(nav_step)
      model.onboarder_progress.keys.include?(nav_step.to_s)
    end

    # returns the path for the high level group steps. If group step has wizard steps,
    # it will return the path for the last completed step.
    def path_with_id(nav_step)
      return nil unless model.onboarder_progress.key?(nav_step.to_s)

      "/onboarding/#{controller_name}/#{nav_step}/#{model.onboarder_progress[nav_step.to_s].last}"
    end

    def controller_name
      h.controller.class.name.underscore.split('/')[1]
    end
  end
end
