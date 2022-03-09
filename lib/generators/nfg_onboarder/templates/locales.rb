en:
  onboarding:
<% if onboarding_group.present? %>
    <%= onboarding_group.underscore %>:
      <%= onboarder_name.underscore %>:
        defaults:
          button: &default_buttons
            back: 'Prev'
            submit: 'Next'
        title_bar:
          caption: "Import Your Data"
          title: "<%= onboarder_name.humanize.titleize %>"
          buttons:
            save_and_exit: 'Save & Exit'
            exit: 'Exit'
        step_navigations:
<% else %>
    <%= onboarder_name.underscore %>:
      defaults:
        button: &default_buttons
          back: 'Prev'
          submit: 'Next'
      title_bar:
        title: "<%= onboarder_name.humanize.titleize %>"
        caption: "Import Your Data"
        buttons:
          save_and_exit: 'Save & Exit'
          exit: 'Exit'
      step_navigations:
<% end %>
# end of file
