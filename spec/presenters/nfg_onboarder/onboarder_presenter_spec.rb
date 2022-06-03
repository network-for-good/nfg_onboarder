require "rails_helper"

describe NfgOnboarder::OnboarderPresenter do
  let(:h) { ApplicationController.new.view_context }
  let(:onboarding_session) { NfgOnboarder::Session.new(current_step: current_step) }
  let(:tested_first_step) { :first }
  let(:tested_last_step) { :last }
  let(:steps) { [tested_first_step, :second, tested_last_step] }
  let(:current_step) { tested_first_step }
  let(:onboarder_presenter) { described_class.new(onboarding_session, h) }
  before do
    allow(h.controller).to receive(:params).and_return(id: current_step)
    allow(h.controller).to receive(:wizard_steps).and_return(steps)
    allow(h.controller).to receive(:onboarding_group_steps).and_return(steps)
  end

  describe '#active_step' do
    subject { onboarder_presenter.active_step }
    let(:current_step) { tested_first_step }
    it { is_expected.to eq tested_first_step }
  end

  describe '#on_first_step?' do
    subject { onboarder_presenter.on_first_step? }
    before { allow(h).to receive(:first_step).and_return(on_first_step) }
    context 'When first_step is true' do
      let(:on_first_step) { true }
      it { is_expected.to be }
    end

    context 'When first_step is false' do
      let(:on_first_step) { false }
      it { is_expected.not_to be }
    end
  end

  describe '#first_step' do
    subject { onboarder_presenter.first_step }
    it { is_expected.to eq tested_first_step }
  end

  describe '#all_steps' do
    subject { onboarder_presenter.all_steps }
    it { is_expected.to eq steps }
  end
end
