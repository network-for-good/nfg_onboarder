require 'rails/generators/base'

module NfgOnboarder
  module Generators
    class OnboarderGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :onboarder_and_group_name, type: :string, required: true
      argument :steps, type: :array, required: true
      # argument :onboarding_group, type: :string, required: false

      def create_controller
        template "controller.rb", controller
      end

      def add_steps_to_controller
        inject_into_file controller, after: "def self.step_list\n" do <<-STRING
    %i[#{ steps_to_symbols }]
        STRING
        end
      end

      def add_on_valid_methods_to_controller
        steps.each do |step_name|
          inject_into_file controller, before: "  # end on valid steps" do <<-STRING
  def #{ step_name }_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

          STRING
          end
        end
      end

      def add_on_before_save_methods_to_controller
        steps.each do |step_name|
          inject_into_file controller, before: "  # end on before save steps" do <<-STRING
  def #{ step_name }_on_before_save
    # you can add logic here to perform an action, such as appending data to the params, before the form is to be saved
  end

          STRING
          end
        end
      end

      def add_get_form_target_entry
        inject_into_file controller, before: "    # catch all" do
          steps.inject("") do |str, step_name|
            str += <<-STRING
    when :#{ step_name.underscore }
      OpenStruct.new(name: '') # replace with your object that the step will update
    STRING
          end
        end
      end

      def create_group_controller
        return unless onboarding_group
        template "group_controller.rb", group_controller
      end

      def create_form
        steps.each do |step_name|
          @step_name = step_name # so we can access step_name in the template
          template "form.rb", "app/forms/onboarding/#{onboarding_path}/#{step_name.underscore}_form.rb"
        end
      end

      def create_view_form
        steps.each do |step_name|
          template "view_form.rb", "app/views/onboarding/#{onboarding_path}/#{step_name.underscore}.html.haml"
        end
      end

      def add_group_level_locales_file
        return unless onboarding_group.present?
        template "group_locales.rb", group_locales_file unless File.exists?(group_locales_file)
        inject_into_file group_locales_file, after: "group_steps:" do <<-STRING
            #{ onboarder_name.underscore }: #{ onboarder_name.titleize }
        STRING
        end
      end

      def add_entries_to_locals_file
        template "locales.rb", locales_file unless File.exists?(locales_file)
        if onboarding_group.present?
          # add the language areas for each page
          steps.each do |step_name|
            inject_into_file locales_file, before: "        step_navigations:" do <<-STRING
        #{step_name.underscore}:
          header:
            message: 'Replace me at config/locales/view/onboarding/#{onboarder_name.underscore}'
            form: 'Replace me too'
            page:
          button:
            <<: *default_buttons
          label:
          placeholder:
          hint:
          guidance:
            modal:
          STRING
            end
          end

          # add the steps to the navigation area
          steps.each do |step_name|
            inject_into_file locales_file, before: "# end of file" do <<-STRING
          #{step_name.underscore}: #{step_name.humanize}
          STRING
            end
          end
        else
          # add the language areas for each page
          steps.each do |step_name|
            inject_into_file locales_file, before: "      step_navigations:" do <<-STRING
      #{step_name.underscore}:
        header:
          message: 'Replace me at config/locales/view/onboarding/#{onboarder_name.underscore}'
          form: 'Replace me too'
          page:
        button:
          <<: *default_buttons
        label:
        placeholder:
        hint:
        guidance:
          modal:
          STRING
            end
          end
          # add the steps to the navigation area
          steps.each do |step_name|
            inject_into_file locales_file, before: "# end of file" do <<-STRING
        #{step_name.underscore}: #{step_name.humanize}
          STRING
            end
          end
        end
      end

      def add_step_navigations
        steps.each do |step_name|
          inject_into_file locales_file, before: "# end of file" do
        "    #{step_name.underscore}:\n"
          end
        end
      end

      def add_high_level_controller_namespace_to_routes
        return unless onboarding_group.present?
        routes_file = 'config/routes.rb'
        inject_into_file routes_file, after: "namespace :onboarding do\n" do <<-STRING
        namespace :#{onboarding_group.underscore} do
        STRING
        end
      end

      def add_controller_to_routes
        routes_file = 'config/routes.rb'
        spacing = ""
        if onboarding_group.present?
          namespace_name = onboarding_group.underscore
          spacing = "  "
        else
          namespace_name = 'onboarding'
        end
        # in order to allow the add_high_level_controller to not duplicate
        # the high level controller in the routes file
        # it does not include the closing end
        # Instead, we add it here when we finish adding the onboarder
        inject_into_file routes_file, after: "namespace :#{namespace_name} do\n" do <<-STRING
    #{ spacing }resources :#{onboarder_name.underscore}, controller: :#{onboarder_name.underscore}
    #{ onboarding_group.present? ? 'end' : '' }
        STRING
        end
      end

      private

      def onboarding_path
        str = ''
        str += "#{onboarding_group.underscore}/" if onboarding_group.present?
        str += onboarder_name.underscore
      end

      def combined_onboarder_name
        str = ''
        str += "#{onboarding_group}::" if onboarding_group.present?
        str += onboarder_name
      end

      def controller
        "app/controllers/onboarding/#{onboarding_path}_controller.rb"
      end

      def group_controller
        "app/controllers/onboarding/#{onboarding_group.underscore}_controller.rb"
      end

      def inherited_controller_name
        if onboarding_group.present?
          "Onboarding::#{onboarding_group}"
        else
          'Onboarding::Base'
        end
      end

      def locales_file
        "config/locales/views/onboarding/#{onboarding_path}.yml"
      end

      def group_locales_file
        "config/locales/views/onboarding/#{onboarding_group.underscore}/#{onboarding_group.underscore}.yml"
      end

      def onboarder_name
        onboarder_and_group_name_split.length == 1 ? onboarder_and_group_name_split.first : onboarder_and_group_name_split.last
      end

      def onboarding_group
        onboarder_and_group_name_split.length == 2 ? onboarder_and_group_name_split.first : nil
      end

      def onboarder_and_group_name_split
        onboarder_and_group_name.split("::")
      end

      def steps_to_symbols
        steps.map { |step_name| ":#{ step_name.underscore }" }.join(", ")
      end

      # def add_step_to_controller
      #   controller = "app/controllers/onboarding/#{onboarder_name.underscore}_controller.rb"
      #   onboarder_steps = Dir["app/forms/onboarding/#{onboarder_name.underscore}/*"].map { |f| File.basename(f).gsub('_form.rb', '').to_sym }
      #   steps_string = "  steps " + onboarder_steps.join(", ")

      #   # This code doesn't work because steps_string doesn't contain symbols.
      #   if File.exists?(controller)
      #     gsub_file controller, /steps.*$/, ''
      #     inject_into_class controller, "Onboarding::#{onboarder_name}Controller", steps_string
      #   else
      #     template "controller.rb", controller
      #   end

      #   #template "controller.rb", controller unless File.exists?(controller)
      # end
    end
  end
end

