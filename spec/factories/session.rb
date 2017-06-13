FactoryGirl.define do
  factory :session, class: NfgOnboarder::Session do
    name 'create_event'
    current_step :contact_info
    current_high_level_step :initial_setup
    owner { FactoryGirl.create(:admin) }
  end
end