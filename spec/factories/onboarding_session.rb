FactoryBot.define do
  factory :onboarding_session, class: Onboarding::Session do
    owner { Testing.create() }
    completed_at { nil }
    name { "import_data_onboarder" }
    entity { FactoryBot.create(:project) }
  end
end
