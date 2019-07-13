require 'rails_helper'

describe 'Testing' do
  let(:test_model) { Testing.new }
  let(:name) { 'name' }
  let(:onboarding_session) { Onboarding::Session.create(name: name, owner: test_model) }
  let(:arg_name) { name }

  before do
    onboarding_session
  end

  describe '#onboarding_session' do
    context 'when name is passed as the argument' do
      subject { test_model.onboarding_session(name: arg_name) }

      context 'when there is a session with the passed name' do
        it "should set the owner" do
          expect(subject.id).to eq(onboarding_session.id)
        end
      end

      context 'when there is no session with the passed name' do
        let(:arg_name) { 'another-name' }

        it 'should be nil' do
          expect(subject).to be_nil
        end
      end
    end

    context 'when there is no name param passed' do
      let(:name) { 'testing_onboarder' }

      subject { test_model.onboarding_session }

      context 'when there is a session with the passed name' do
        it "should get the onboarding_session" do
          expect(subject.id).to eq(onboarding_session.id)
        end
      end

      context 'when there is no session with the passed name' do
        let(:name) { 'another-name' }

        it 'should be nil' do
          expect(subject).to be_nil
        end
      end
    end
  end

end
