require 'spec_helper'

describe NfgOnboarder::UrlGenerator do

  let(:admin) { build_stubbed(:admin) }

  let!(:onboarding_session) do
    create(:session,
           user: admin,
           onboarder_prefix: 'create_campaign',
           completed_high_level_steps: [],
           current_high_level_step: 'recruit_fundraisers',
           current_step: 'wicked_finish',
           onboarder_progress: {
           }
          )
  end

  subject { NfgOnboarder::UrlGenerator.new(onboarding_session).call }

  it "should return the path to the wicked finish step of the empowering fundraisers controller" do
    expect(subject).to eq('/onboarding/create_campaign/recruit_fundraisers/wicked_finish')
  end

  describe "an initial setup onboarding session on the account step" do
    let!(:onboarding_session) do
      create(:session,
             user: admin,
             onboarder_prefix: nil,
             current_high_level_step: 'create_project',
             current_step: 'project_name',
            )
    end

    it { should eq('/onboarding/create_project/project_name') }

  end

end