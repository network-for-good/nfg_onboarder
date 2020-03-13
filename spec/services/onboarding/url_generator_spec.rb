# frozen_string_literal: true

require 'rails_helper'

describe NfgOnboarder::UrlGenerator do
  let(:admin) { create(:admin) }
  let(:context) { ActionController::Base.new.view_context }

  let!(:onboarding_session) do
    create(:session,
           owner: admin,
           onboarder_prefix: 'create_project',
           completed_high_level_steps: [],
           current_high_level_step: 'project_name',
           current_step: 'wicked_finish',
           onboarder_progress: {
           }
    )
  end

  subject { NfgOnboarder::UrlGenerator.new(onboarding_session, context).call }

  it "should return the path to the wicked finish step of the create project controller" do
    expect(subject).to eq('/onboarding/create_project/wicked_finish')
  end

  describe "an initial setup onboarding session on the project name step" do
    let!(:onboarding_session) do
      create(:session,
             owner: admin,
             onboarder_prefix: nil,
             current_high_level_step: 'create_project',
             current_step: 'project_name',
            )
    end

    it { should eq('/onboarding/create_project/project_name') }
  end
end
