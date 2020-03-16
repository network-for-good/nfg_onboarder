# frozen_string_literal: true

require 'rails_helper'

describe NfgOnboarder::UrlGenerator do
  let(:admin) { create(:admin) }
  let(:context) { ActionController::Base.new.view_context }

  subject { NfgOnboarder::UrlGenerator.new(onboarding_session, context).call }

  describe 'when using a multi-level onboarder' do
    let!(:onboarding_session) do
      create(:session,
             owner: admin,
             onboarder_prefix: 'create_campaign',
             completed_high_level_steps: [],
             current_high_level_step: 'recruit_fundraisers',
             current_step: 'wicked_finish',
             onboarder_progress: {
             }
      )
    end

    it "should return the path to the wicked finish step of the create project controller" do
      expect(subject).to eq('/onboarding/create_campaign/recruit_fundraisers/wicked_finish')
    end
  end

  describe "with a single level onboarder" do
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
