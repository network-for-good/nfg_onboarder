require 'rails_helper'

shared_examples_for "raising a method missing exception" do
  it "raises a method missing exception" do
    expect { session.admin }.to raise_exception(NoMethodError)
  end
end

describe NfgOnboarder::Session do
  let(:session) { FactoryBot.create :session }

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

        let!(:session) do
          begin
            s = build(:session, related_objects: { admin: admin })
            s.validate
            puts s.errors.full_messages.to_sentence
            Rails.logger.error s.errors.full_messages.to_sentence
            s.save!
            s
          rescue StandardError => e
            puts "#{e.class}: #{e.message}"
            Rails.logger.error "#{e.class}: #{e.message}"
            s
          end
        end

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

  describe "complete!" do
    let(:onboarding_session) { create(:session, completed_at: completed_at) }

    subject { onboarding_session.complete! }

    context "when the onboarding session is already complete" do
      let(:completed_at) { DateTime.now }
      it { should be_falsey }
    end

    context "when the onboarding session hasn't been completed yet" do
      let(:completed_at) { nil }
      it { should be_truthy }
      it "timestamps the field" do
        expect { subject }.to change { onboarding_session.reload.completed_at }.from(nil)
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

  describe 'started?' do
    subject { session.started? }

    context 'when the created_at and updated_at values are the same' do
      it 'should be falsey' do
        session
        expect(subject).to be_falsey
      end
    end

    context "whent the created_at and updated_at values are different" do
      it 'should be truthy' do
        session.update(onboarder_progress: { "initial_setup" => [:contact_info]})
        expect(subject).to be_truthy
      end

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
