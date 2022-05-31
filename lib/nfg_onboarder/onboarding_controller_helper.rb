module NfgOnboarder
  module OnboardingControllerHelper
    extend ActiveSupport::Concern

    included do
      layout "onboarding"

      helper NfgOnboarder::ApplicationHelper

      before_action :maybe_jump_to_last_visited_step, only: :show
      before_action :maybe_jump_to_next_step, only: :show
      before_action :maybe_jump_to_last_visited_point_of_no_return, only: :show

      expose(:onboarding_admin) { get_onboarding_admin }
      expose(:form) { get_form_object }
      # assume the onboarding session is associated with an admin. This won't be the case for donor related
      # onboarding sessions. This exposure will need to be overwritten there.
      expose(:onboarding_session) { get_onboarding_session }
      expose(:first_step) do
        if onboarding_group_steps.present?
          onboarding_group_steps.first == locale_namespace.last.to_sym
        else
          steps.first == step
        end
      end
      expose(:last_step) do
        if onboarding_group_steps.present?
          onboarding_group_steps.last == locale_namespace.last.to_sym
        else
          steps.last == step
        end
      end
      expose(:locale_namespace) { self.class.name.underscore.gsub('_controller', '').split('/') }
      expose(:form_params) { params.fetch("#{field_prefix}_#{step}", {}).permit! }
      expose(:exit_without_saving?) { (exit_without_save_steps || []).map(&:to_sym).include?(onboarding_session.current_step.try(:to_sym)) }
      expose(:use_recaptcha?) { false }
      expose(:exit_without_saving_path) { finish_wizard_path }

      # This gets prepended to a value of a route.  finished_wizard_path then redirects to this route
      ALT_FINISH_PATH_PREPEND_KEY ||= 'alternative_finished_wizard_path'

      def show
        on_before_show
        render_wizard
      end

      def update
        redirect_to finish_wizard_path and return if exit_without_saving? && exit?
        if (!use_recaptcha? || verify_recaptcha(model: form)) && form.validate(form_params)
          on_before_save
          form.save
          on_valid_step
          process_on_last_step if last_step
          # redirect if exit hasn't happened already
          # exit can sometimes happen in onboarders where on_valid_method is overriden to redirect
          binding.pry
          redirect_to finish_wizard_path and return if exit? && !performed?
        else
          on_invalid_step
        end
        render_wizard(nil, {}, finish_wizard_params) unless performed?
      end

      def single_use_steps
        []
      end

      def points_of_no_return
        []
      end

      # this specifies steps that should exit before saving the current step when exiting the onboarder
      def exit_without_save_steps
        []
      end

      protected

      def on_before_save
        self.send("#{step}_on_before_save") if self.respond_to?("#{step}_on_before_save", true)
      end

      private

      def maybe_jump_to_last_visited_point_of_no_return
        jump_to(last_visited_point_of_no_return) if before_last_visited_point_of_no_return?
      end

      def before_last_visited_point_of_no_return?(step_to_check = nil)
        step_to_check ||= step

        return unless last_visited_point_of_no_return.present?
        return unless onboarder_progress_with_current_step.present?
        return unless index_of_step_to_check = onboarder_progress_with_current_step.index(step_to_check.to_sym)

        index_of_step_to_check < onboarder_progress_with_current_step.index(last_visited_point_of_no_return)
      end

      helper_method :before_last_visited_point_of_no_return?

      def last_visited_point_of_no_return
        return unless points_of_no_return.present?
        return unless onboarder_progress.present?

        onboarder_progress_with_current_step.reverse.detect do |progress_step|
          points_of_no_return.include?(progress_step.to_sym)
        end
      end

      def onboarder_progress_with_current_step
        (onboarder_progress || []) + [onboarding_session.current_step.to_sym]
      end

      def at_point_of_no_return?
        points_of_no_return.include?(step.to_sym)
      end

      helper_method :at_point_of_no_return?

      def onboarder_progress
        onboarding_session.onboarder_progress[controller_name]
      end

      def redirect_to_finish_wizard(options, params)
        redirect_to(finish_wizard_path + "?from_wicked_finish=true", options)
      end

      def maybe_jump_to_last_visited_step
        # We can get stuck in a redirect loop if an onboarding_session's current_step is
        # set to wicked_finish and the onboarder is re-entered from e.g. the campaigns index page.
        # We set the from_wicked_finish param by redefining wicked wizard's #redirect_to_finish_wizard.

        return if params[:from_wicked_finish]
        return unless onboarding_admin
        return unless onboarding_session
        return if referred_by_us?
        return if onboarding_session.onboarder_progress.empty?
        return unless onboarding_session.current_high_level_step.present?
        # do not redirect if the current onboarding controller has never been visited
        return unless onboarding_session.onboarder_progress.has_key?(controller_name)
        # do not redirect if the current onboarding controller and step match what has been completed
        return if onboarding_session.does_current_completed_step_match_current_step?(controller_name, step)

        redirect_to NfgOnboarder::UrlGenerator.new(onboarding_session, self).call and return
      end

      def maybe_jump_to_next_step
        return if single_use_steps.empty?
        return if onboarding_session.onboarder_progress.empty?
        return unless onboarding_session.onboarder_progress[controller_name].include?(step.to_sym)
        return unless self.single_use_steps.include?(step.to_sym)
        referred_by_us? ? jump_to(onboarding_session.current_step) : next_step
      end

      def cleansed_param_data
        form_params.dup.delete_if { |key, value| fields_to_be_cleansed_from_form_params.include?(key)}
      end

      def fields_to_be_cleansed_from_form_params
        %w{ }
      end

      def get_form_object
        # here we are trying two different ways to check whether there is a form defined for this step
        # Object.const_get seems to be failing sometimes when constantize works. But it is not clear why
        # so we try both, rescuing if an error is raised.
        if (Object.const_get(get_form_object_name) rescue false) || (get_form_object_name.constantize rescue false)
          get_form_object_name.constantize.new(get_form_target)
        else
          #supply a dummy form
          p "here"
          NfgOnboarder::InformationalForm.new(OpenStruct.new(name: ''))
        end
      end

      def get_form_object_name
        "::#{self.class.name.gsub('Controller', '')}::#{step.to_s.camelize}Form"
      end

      def get_onboarding_admin
        current_admin
      end

      def get_previous_step_data(onboarder, step)
        #move to an instance method on onboarding session
        onboarding_session.step_data[onboarder].try(:[],step)
      end

      def on_before_show
        self.send("#{step}_on_before_show") if self.respond_to?("#{step}_on_before_show", true)
      end

      def on_valid_step
        onboarding_session.current_high_level_step = controller_name
        onboarding_session.current_step = next_step
        # below we need to check for the CollectionProxy as during the course of an onboarder
        # there may be different objects for form.model.  we need to check if this object has onboarding_sessions
        # which will confirm that this object then can be the owner
        onboarding_session.owner = get_event_target if onboarding_session.owner.nil? && get_event_target&.onboarding_sessions&.is_a?(ActiveRecord::Associations::CollectionProxy)
        update_onboarding_session_step_data
        update_onboarding_session_progress
        self.send("#{step}_on_valid_step") if self.respond_to?("#{step}_on_valid_step", true)
        onboarding_session.save
        jump_to(@override_next_step || next_step) unless @stay_on_step
      end

      def get_onboarding_session
        raise 'This should be overriden in the containing controller'
      end

      def jump_to_step(new_step)
        # this allows you to move from any step to any future step
        # and updates the session to act as if you have completed
        # any steps that would be in between
        @override_next_step = new_step #used by the onvalid step to get the user to the next step
        steps.each do |this_step|
          break if steps.index(this_step) >= steps.index(new_step)
          onboarding_session.onboarder_progress[controller_name] << this_step unless onboarding_session.onboarder_progress[controller_name].include?(this_step)
        end
        onboarding_session.current_step = new_step
      end

      def onboarder_name
        raise 'This should be overriden in the containing controller'
        # for onboarders that are using group steps, it should be in the group controller, not in the sub controllers.
      end
      helper_method :onboarder_name

      def on_invalid_step
        flash.now[:error] = "There was an error in your submission. Please see below for more details."
        self.send("#{step}_on_invalid_step") if self.respond_to?("#{step}_on_invalid_step", true)
      end

      def process_on_last_step
        onboarding_session.completed_high_level_steps << controller_name unless onboarding_session.completed_high_level_steps.include?(controller_name)
      end

      def redirect_unless_onboarding_admin
        if onboarding_admin.nil?
          redirect_to sso_openid.auth_path
        end
      end

      def redirect_unless_onboarding_session
        if ! onboarding_admin.onboarding_session_for(onboarder_name).present?
          redirect_to sso_openid.auth_path
        end
      end

      def update_onboarding_session_step_data
        onboarding_session.step_data = {} if onboarding_session.step_data.nil?
        onboarding_session.step_data[controller_name] = {} if onboarding_session.step_data[controller_name].nil?
        onboarding_session.step_data[controller_name] = onboarding_session.step_data[controller_name].merge({step => cleansed_param_data })
      end

      def update_onboarding_session_progress
        onboarding_session.onboarder_progress = {} if onboarding_session.onboarder_progress.nil?
        onboarding_session.onboarder_progress[controller_name] = [] if onboarding_session.onboarder_progress[controller_name].nil?
        onboarding_session.onboarder_progress[controller_name] << step unless onboarding_session.onboarder_progress[controller_name].include?(step)
      end

      def field_prefix
        self.class.name.gsub('Controller', '').underscore.gsub('/','_')
      end

      def referred_by_us?
        if request.referrer.present?
          request.referrer.gsub(/https?:\/\//, '').split('/')[2] == request.path.split('/')[2]
        end
      end

      def get_event_target
        if form.model.respond_to?(:persisted?) && form.model.persisted?
          form.model
        else
          nil
        end
      end

      def finish_wizard_params
        # In some cases we need to be able to return a user to different location then the default finish wizard path. We do this by placing a button on the last step of the onboarder whose name is prefixed with the ALT_FINISH_PATH_PREPEND_KEY and suffixed with the alternative path that we want the user sent to (i.e "#{ALT_FINISH_PATH_PREPEND_KEY}_#{path/to/other/destination}"). Clicking the button still takes the user through the last step (and the on_valid method related to that step), but instead of redirecting the user to the default finish wizard destination, it redirects them to the alternative path.
        # This can only be used on the last step, as it is tied to the finish wizard path. Any number of buttons, with different paths, can be included on that last step.

        return {} unless last_step
        finished_wizard_param = params.keys.select { |key| key.include?(ALT_FINISH_PATH_PREPEND_KEY) }.first # check if params include alternative finish path
        return {} if finished_wizard_param.nil?
        finished_wizard_url = finished_wizard_param&.remove("#{ALT_FINISH_PATH_PREPEND_KEY}_") # retrieve the alternative path
        params.merge!({ ALT_FINISH_PATH_PREPEND_KEY => finished_wizard_url })
        params.select { |key| key == ALT_FINISH_PATH_PREPEND_KEY }.permit!
      end

      def exit?
        params[:exit] == 'true'
      end
    end
  end
end
