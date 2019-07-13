FactoryBot.define do
  factory :onboarding_session, class: Onboarding::Session do
    owner NfgOnboarder::Testing.new
    completed_at nil
    name "import_data"
  end
end
