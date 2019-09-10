module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::HighLevelNavigationBarPresenter.new(onboarding_session, self)
  class HighLevelNavigationBarPresenter < NfgOnboarder::GemPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(step, path: '')
      h.before_last_visited_point_of_no_return?(step) ? nil : path
    end

    def points_of_no_return
      @points_of_no_return ||= h.controller.send(:points_of_no_return)
    end

    # set this to false on your own presenter if you would like to hide
    # the nav, for example to hide on the first step:
    #
    # active_step.to_sym != first_step
    def show_nav?
      true
    end

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