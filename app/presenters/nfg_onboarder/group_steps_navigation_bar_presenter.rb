# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::GroupStepsNavigationBarPresenter.new(onboarding_session, self)
  class GroupStepsNavigationBarPresenter < NfgOnboarder::OnboarderNavigationBarPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(nav_step, path = '')
      h.before_last_visited_point_of_no_return?(nav_step) ? nil : path_with_id(nav_step)
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

      "/onboarding/#{controller_name[1]}/#{nav_step}/#{model.onboarder_progress[nav_step.to_s].last}"
    end

    def controller_name
      h.controller.class.name.underscore.split('/')
    end

    # previous_wizard_path is the last step that was visited in the group. It is used to
    # determine the previous step but it is not the actual previous step when it comes to
    # the first step of the group. So we need to check if the previous_wizard_path is the
    # first step of the group or not. If it is the first step of the group, we need to return
    # the previous_group_path. Otherwise, we need to return the previous_wizard_path.
    def previous_path
      return h.controller.previous_group_path if h.controller.previous_wizard_path == active_group_path

      h.controller.previous_wizard_path
    end

    # Returns the active group step from the controller.
    def active_group_step
      controller_name.last.split('_')[0...-1].join('_')
    end

    # Returns the path for the active group step.
    def active_group_path
      "/onboarding/#{controller_name[1]}/#{active_group_step}/#{active_step}"
    end
  end
end
