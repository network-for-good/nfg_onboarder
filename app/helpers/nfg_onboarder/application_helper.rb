module NfgOnboarder
  module ApplicationHelper
    def has_flash?(flash)
      return false if flash.empty?
      return false unless flash.keys.delete_if { |key| key == "kiss_metrics" }.present?
      true
    end

    def calculate_onboarding_nav_status(nav_step, all_steps, current_step)
      return '' if all_steps.index(nav_step).nil? || all_steps.index(current_step).nil?
      return onboarding_nav_classes[:active] if nav_step == current_step
      return onboarding_nav_classes[:success] if onboarding_session.try(:completed_steps, controller_name).try(:include?, nav_step)
      return onboarding_nav_classes[:disabled]
    end

    def get_onboarding_nav_status(nav_step)
      calculate_onboarding_nav_status(nav_step, controller.wizard_steps, controller.step)
    end

    def onboarding_nav_classes
      { success: 'text-success',
        active: 'active',
        disabled: 'disabled',
        link_success: 'text-success',
        incomplete: 'text-info'}
    end

    def calculate_onboarding_high_level_nav_status(nav_step, all_steps, controller_name)
      return '' if all_steps.index(nav_step.to_sym).nil? || all_steps.index(controller_name.to_sym).nil?
      return onboarding_nav_classes[:active] if nav_step.to_s == controller_name.to_s
      return onboarding_nav_classes[:success] if onboarding_session.completed_high_level_steps.include?(nav_step.to_s)
      return onboarding_nav_classes[:incomplete] if onboarding_session.onboarder_progress[nav_step.to_s].present? and !onboarding_session.completed_high_level_steps.include?(nav_step.to_s)
      return onboarding_nav_classes[:disabled]
    end

    def get_onboarding_high_level_nav_status(nav_step)
      calculate_onboarding_high_level_nav_status(nav_step, onboarding_group_steps, controller_name)
    end

    def color_status_class(color)
      color_is_selected?(color) ? 'active' : 'inactive'
    end

    def project_has_essential_info?
      project.fund_raising_goal.present? &&
        project.end_date.present? &&
        project.photo.try(:file).try(:exists?)
    end

    def navbar_link_class
      entity.main_logo.present? ? 'navbar-brand image' : 'navbar-brand text'
    end

    private

    def color_is_selected?(color)
      return false unless onboarding_session.step_data[controller_name].has_key?(:theme)
      onboarding_session.step_data[controller_name][:theme][:selected_color_swatch] == color.to_s
    end
  end
end