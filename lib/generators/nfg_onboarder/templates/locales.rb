en:
  onboarding:
<% if onboarding_group.present? -%>
    <%= onboarding_group.underscore %>:
      <%= onboarder_name.underscore %>:
        step_navigations:
<% else %>
    <%= onboarder_name.underscore %>:
      step_navigations:
<% end %>
