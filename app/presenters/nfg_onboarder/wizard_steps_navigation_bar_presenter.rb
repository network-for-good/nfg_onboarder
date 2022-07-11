# frozen_string_literal: true

module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::WizardStepsNavigationBarPresenter.new(onboarding_session, self)
  class WizardStepsNavigationBarPresenter < NfgOnboarder::OnboarderNavigationBarPresenter
    # Ensure that the href is nil (thus supporting accessibility via the nfg_ui Step)
    # when the step is disabled / unclickable
    # or on the last step, all links should have a nil :href
    def href(nav_step, path: '')
      # returns nil if the navigation is secondary breadcrumbs navigation.
      return nil if options[:breadcrumb] && (active?(nav_step) || !visited?(nav_step))

      h.before_last_visited_point_of_no_return?(nav_step) ? nil : path
    end

    # Provide a custom locale lookup
    # for the step nav body text
    # or default to humanizing the
    # step's symbol.
    def step_body(nav_step)
      if nav_step.to_sym == :submit_for_review && !h.controller.required_approval?
        I18n.t('onboarding.create_fundraiser.launch_your_campaign.step')
      else
        I18n.t(nav_step, scope: h.locale_namespace + [:step_navigations], default: nav_step.to_s.titleize)
      end
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

    def previous_path
      h.controller.previous_wizard_path
    end
  end
end
