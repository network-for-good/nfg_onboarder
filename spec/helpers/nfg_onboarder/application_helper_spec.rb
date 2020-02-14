require 'rails_helper'

RSpec.describe NfgOnboarder::ApplicationHelper, type: :helper do

  describe "#calculate_onboarding_nav_status" do
    before(:each) do
      allow(helper).to receive(:onboarding_session).and_return(NfgOnboarder::Session.new(onboarder_progress: onboarder_progress))
      allow(helper).to receive(:controller_name).and_return(controller_name)
      allow(controller).to receive(:single_use_steps) { single_use_steps }
    end
    let(:calculate_onboarding_nav_status) { helper.calculate_onboarding_nav_status(nav_step, all_steps, current_step) }
    let(:all_steps) { [:account, :goal, :theme, :story] }

    let(:nav_step) { :account }
    let(:current_step) { :account }
    let(:controller_name) { 'empowering_fundraisers' }
    let(:onboarder_progress) { {'empowering_fundraisers' => [:goal]} }
    let(:single_use_steps) { [] }

    subject { calculate_onboarding_nav_status }

    context "when the nav step is the current step" do
      it "should return 'active'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:active])
      end
    end

    context "when the nav step is listed in the progress has as having been completed" do
      let(:nav_step) { :goal }
      let(:current_step) { :theme }

      it "should return 'bg-success'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:success])
      end
    end

    context "when the nav step is not in the onboarder progress list" do
      let(:nav_step) { :theme }
      let(:current_step) { :goal }
      it "should return 'disabled'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:disabled])
      end
    end

    context "when the nav step is not in the list of all steps" do
      let(:nav_step) { :bogus }
      it "should return ''" do
        expect(subject).to eq('')
      end
    end

    context "when the current step is not in the list of all steps" do
      let(:current_step) { :bogus }
      it "should return ''" do
        expect(subject).to eq('')
      end
    end

    describe "when the nav step is a single use step" do
      let(:single_use_steps) { [:goal] }

      before do
        allow(controller).to receive(:single_use_steps) { single_use_steps }
        allow(controller).to receive(:current_step) { current_step }
      end

      context "as the current step" do
        let(:current_step) { :goal }
        let(:nav_step) { :goal }
        it { should eq 'active' }
      end

      context "as another step" do
        let(:current_step) { :theme }
        it { should eq 'disabled' }
      end
    end
  end

  describe "#get_onboarding_nav_status" do
    before do
      allow(controller).to receive(:step).and_return(:my_current_step)
      allow(controller).to receive(:wizard_steps).and_return(:my_wizard_steps)
    end

    subject { helper.get_onboarding_nav_status(:my_nav_step) }

    it "should use the controller's current_step and wizard_steps" do
      expect(helper).to receive(:calculate_onboarding_nav_status).with(:my_nav_step, :my_wizard_steps, :my_current_step)
      subject
    end

  end

  describe "#calculate_onboarding_high_level_nav_status" do
    before(:each) do
      allow(helper).to receive(:onboarding_session).and_return(NfgOnboarder::Session.new(completed_high_level_steps: completed_high_level_steps, onboarder_progress: onboarder_progress))
      allow(helper).to receive(:controller_name).and_return(controller_name)
    end
    let(:calculate_onboarding_high_level_nav_status) { helper.calculate_onboarding_high_level_nav_status(high_level_nav_step, all_high_level_steps, controller_name) }
    let(:all_high_level_steps) { [:high_level_1, :high_level_2, :high_level_3] }

    let(:high_level_nav_step) { "high_level_3" }
    let(:controller_name) { "high_level_3" }
    let(:completed_high_level_steps) { ['high_level_1'] }
    let(:onboarder_progress) { {'high_level_2' => [:goal], 'high_level_1' => [:pickup, :dropoff]} }


    subject { calculate_onboarding_high_level_nav_status }

    context "when the high_level nav step is the current step" do
      it "should return 'active'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:active])
      end
    end

    context "when the high_level nav step is listed in the completed high level steps" do
      let(:high_level_nav_step) { 'high_level_1' }
      let(:controller_name) { 'high_level_2' }

      it "should return 'bg-success'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:success])
      end
    end

    context "when the high_level nav step not in completed high level steps but is listed in the onboarder progress" do
      let(:high_level_nav_step) { 'high_level_2' }
      let(:controller_name) { 'high_level_3' }

      it "should return 'bg-success'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:incomplete])
      end
    end

    context "when the high_level nav step is not in list of completed high level steps and not in the onboarder_progress" do
      let(:high_level_nav_step) { 'high_level_3' }
      let(:controller_name) { 'high_level_1' }
      it "should return 'disabled'" do
        expect(subject).to eq(helper.onboarding_nav_classes[:disabled])
      end
    end

    context "when the high level nav step is not in the list of all high level steps" do
      let(:high_level_nav_step) { 'not_a_step' }
      it "should return ''" do
        expect(subject).to eq('')
      end
    end

    context "when the current step is not in the list of all high level steps" do
      let(:controller_name) { 'not_a_step2' }
      it "should return ''" do
        expect(subject).to eq('')
      end
    end
  end

  describe "#get_onboarding_high_level_nav_status" do
    before do
      allow(controller).to receive(:controller_name).and_return("my_controller")
      allow(helper).to receive(:onboarding_group_steps).and_return(['this', 'that'])
    end

    subject { helper.get_onboarding_high_level_nav_status('my_high_level_nav_step') }

    it "should use the controller's current_step and wizard_steps" do
      expect(helper).to receive(:calculate_onboarding_high_level_nav_status).with("my_high_level_nav_step", ['this', 'that'], "my_controller")
      subject
    end

  end

end