require 'rails_helper'

shared_examples_for "raising a method missing exception" do
  it "raises a method missing exception" do
    expect { session.admin }.to raise_exception(NoMethodError)
  end
end

describe NfgOnboarder::Session do
  let(:session) { FactoryGirl.create :session }

  it { is_expected.to belong_to :owner }

  it { is_expected.to serialize(:step_data).as(Hash) }
  it { is_expected.to serialize(:completed_high_level_steps).as(Array) }
  it { is_expected.to validate_presence_of(:name) }

  describe "related objects=" do
    subject { session.related_objects }

    context "when the record is unsaved" do
      context "with no related objects" do
        let(:session) { NfgOnboarder::Session.new(name: 'create_event', related_objects: nil) }
        it { should be_empty }
        it_behaves_like "raising a method missing exception"
      end

      context "when there are related objects" do
        let(:admin) { create(:admin) }
        let(:session) { NfgOnboarder::Session.new(name: 'create_event', related_objects: { admin: admin }) }
        it "builds the related object" do
          expect(subject.first.target_id).to eql(admin.id)
        end

        it "does not save the related_object" do
         expect_any_instance_of(NfgOnboarder::RelatedObject).to receive(:save).never
          subject
        end
      end
    end

    context "when the record is saved" do
      context "with no related objects" do
        let(:session) { create(:session, related_objects: nil) }
        it { should be_empty }
        it_behaves_like "raising a method missing exception"
      end

      context "when there are related objects" do
        let(:admin) { create(:admin) }
        let(:session) { create(:session, related_objects: { admin: admin }) }

        it "returns the related object" do
          expect(session.admin).to eql(admin)
        end

        it "saves the related object" do
          expect_any_instance_of(NfgOnboarder::RelatedObject).to receive(:save).once
          subject
        end
      end
    end

    describe "Adding a new related object when other objects are present" do
      let(:admin) { create(:admin) }
      let(:other_admin) { create(:admin) }
      let(:session) { create(:session, related_objects: { other_admin: other_admin }) }

      before { session.update(related_objects: { admin: admin }) }

      it "stores the new object" do
        expect(session.admin).to eql(admin)
      end

      it "retains the existing object" do
        expect(session.other_admin).to eql(other_admin)
      end
    end
  end

  describe "complete?" do
    subject { session.complete? }

    before do
      allow(session).to receive(:completed_at).and_return(completed_at)
    end
    context "when completed at has a value'" do
      let(:completed_at) { DateTime.now }
      it "should be true" do
        expect(subject).to be
      end

    end

    context "when completed_at does not have a value" do
      let(:completed_at) {  }
      it "should be true" do
        expect(subject).to_not be
      end

    end
  end


  describe "#completed_steps" do
    before do
      session.onboarder_progress = {:first_step=>[:goal, :final], :last_step=>[:bert]}
      session.current_high_level_step = :first_step
    end

    subject { session.completed_steps(:first_step) }

    it "should return an array of the completed steps for the current_high_level_step" do
      expect(subject).to eq([:goal, :final])
    end
  end

  describe "destroying related objects" do
    let(:parent_admin) { create(:admin) }
    let!(:session) { create(:session, related_objects: { parent_admin: parent_admin }) }

    subject { session.destroy }

    it "destroys the onboarding session" do
      expect{ subject }.to change{ NfgOnboarder::RelatedObject.count }.by(-1)
    end
  end

end

def onboarding_configuration
  @high_level_steps = {
    get_ready: [:step_by_step_for_success],
    consider_your_audience: [:identify_your_fundraisers],
    campaign_goal_and_length: [:visualize_the_campaign, :set_your_goal, :campaign_length],
    fundraiser_recruitment: [:get_ready, :campaign_focus, :content_to_solicit_fundraisers, :recruit_fundraisers, :motivate_fundraisers, :preview_recruitment_page],
    empowering_fundraisers: [:get_ready, :kicking_off_fundraisers_campaign, :solicting_donations, :collecting_donations, :thanking_donors],
    review_campaign: [:summary, :next_steps]
  }
end