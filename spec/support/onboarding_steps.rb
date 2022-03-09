def click_onboarding_next_button(onboarder, step)
  scroll_to_element("form")
  within("form") do
    click_button I18n.t(:submit, scope: [:onboarding, onboarder, step, :button])
  end
end

def click_onboarding_back_button(onboarder)
  click_link 'onboarder_back_button'
end
