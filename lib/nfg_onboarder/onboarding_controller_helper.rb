module NfgOnboarder
  module OnboardingControllerHelper
    extend ActiveSupport::Concern

    included do
      layout "onboarding"

      helper NfgOnboarder::ApplicationHelper

      before_filter :maybe_jump_to_last_visited_step, only: :show

      expose(:onboarding_admin) { get_onboarding_admin }
      expose(:form) { get_form_object }
      # assume the onboarding session is associated with an admin. This won't be the case for donor related
      # onboarding sessions. This exposure will need to be overwritten there.
      expose(:onboarding_session) { get_onboarding_session }
      expose(:first_step) { steps.first == step }
      expose(:last_step) { steps.last == step }
      expose(:locale_namespace) { self.class.name.underscore.gsub('_controller', '').split('/') }
      expose(:form_params) { params.fetch("#{field_prefix}_#{step}", {}).permit! }

      def show
        on_before_show
        render_wizard
      end

      def update
        if form.validate(form_params)
          on_before_save
          form.save
          on_valid_step
          process_on_last_step if last_step
        else
          on_invalid_step
        end
        render_wizard unless performed?
      end

      protected

      def on_before_save
        self.send("#{step}_on_before_save") if self.respond_to?("#{step}_on_before_save", true)
      end

      private

      def redirect_to_finish_wizard(options)
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

        redirect_to NfgOnboarder::UrlGenerator.new(onboarding_session).call and return
      end

      def cleansed_param_data
        fields_to_be_cleansed_from_form_params = %w{ main_logo password password_confirmation photo}
        form_params.dup.delete_if { |key, value| fields_to_be_cleansed_from_form_params.include?(key)}
      end

      def get_form_object
        if (Object.const_get(get_form_object_name) rescue false)
          get_form_object_name.constantize.new(get_form_target)
        else
          #supply a dummy form
          NfgOnboarder::InformationalForm.new(OpenStruct.new(name: ''))
        end
      end

      def get_form_object_name
        "#{self.class.name.gsub('Controller', '')}::#{step.to_s.camelize}Form"
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
        update_onboarding_session_step_data
        update_onboarding_session_progress
        self.send("#{step}_on_valid_step") if self.respond_to?("#{step}_on_valid_step", true)
        onboarding_session.save
        jump_to(next_step) unless @stay_on_step
      end

      def get_onboarding_session
        raise 'This should be overriden in the containing controller'
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
    end
  end
end