require "rails_helper"

describe NfgOnboarder::HighLevelNavigationBarPresenter do
  let(:h) { ApplicationController.new.view_context }
  let(:high_level_navigation_bar_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(current_step: current_step) }
  let(:tested_first_step) { :first }
  let(:tested_last_step) { :last }
  let(:steps) { [tested_first_step, :second, tested_last_step] }
  let(:current_step) { tested_first_step }
  let(:on_first_step) { current_step == tested_first_step }

  before do
    allow(h.controller).to receive(:params).and_return(id: current_step)
    allow(h.controller).to receive(:wizard_steps).and_return(steps)
    allow(h).to receive(:first_step).and_return(on_first_step)
  end

  describe "#href(step, path: '')" do
    let(:tested_step) { :first }
    let(:tested_path) { nil }
    let(:before_point_of_no_return) { nil }
    subject { high_level_navigation_bar_presenter.href(tested_step, path: tested_path) }

    before { allow(h).to receive(:before_last_visited_point_of_no_return?).with(tested_step).and_return(before_point_of_no_return) }

    context 'when #before_last_visited_point_of_no_return? is true' do
      let(:before_point_of_no_return) { true }
      it 'returns nil so that the step is not clickable' do
        expect(subject).to be_nil
      end
    end

    context 'when #before_last_visited_point_of_no_return? is false' do
      let(:before_point_of_no_return) { false }
      let(:tested_path) { '/tested/path' }
      it 'returns the path so that the step is clickable' do
        expect(subject).to eq tested_path
      end
    end
  end

  describe '#points_of_no_return' do
    subject { high_level_navigation_bar_presenter.points_of_no_return }
    let(:tested_points_of_no_return) { [current_step] }

    before { allow(h.controller).to receive(:points_of_no_return).and_return(tested_points_of_no_return) }

    it "provides easy access to the controller's points_of_no_return by returning the controller's points_of_no_return" do
      expect(subject).to eq tested_points_of_no_return
    end
  end

  describe '#render_previous_button_unless?' do
    subject { high_level_navigation_bar_presenter.render_previous_button_unless? }

    let(:tested_single_use_steps) { [] }
    let(:tested_at_point_of_no_return) { false } # a native state
    let(:previous_step) { nil }

    before do
      allow(h.controller).to receive(:single_use_steps).and_return(tested_single_use_steps)
      allow(h.controller).to receive(:previous_step).and_return(previous_step)
      allow(h).to receive(:at_point_of_no_return?).and_return(tested_at_point_of_no_return)
    end

    describe 'current step position' do
      context 'when the current step is the first step' do
        let(:current_step) { tested_first_step }
        it { is_expected.to be }
      end

      context 'when the current step is not the first step' do
        let(:current_step) { tested_last_step }
        it { is_expected.not_to be }
      end
    end

    describe 'single use steps' do
      let(:tested_single_use_steps) { [tested_first_step] }

      context 'when the previous step is a single use step' do
        let(:current_step) { :second }
        let(:previous_step) { tested_single_use_steps.first }

        it { is_expected.to be }
      end

      context 'when the previous step is not a single use step' do
        let(:previous_step) { :second }
        let(:current_step) { tested_last_step }
        it { is_expected.not_to be }
      end
    end

    describe 'point of no return' do
      context 'when the current step is a point of no return' do
        let(:current_step) { tested_last_step }
        let(:tested_at_point_of_no_return) { true }
        it { is_expected.to be }
      end

      context 'when the current step is not at a point of no return' do
        # must use the last step since the first step is automatically disqualified
        let(:current_step) { tested_last_step }
        let(:tested_at_point_of_no_return) { false }
        it { is_expected.not_to be }
      end
    end
  end

  describe '#step_body(step)' do
    subject { high_level_navigation_bar_presenter.step_body(step) }

    let(:locale_namespace) { [] }
      before { allow(h).to receive(:locale_namespace).and_return(locale_namespace) }

    # could not figure out how to test the alternative context of this to verify the onboarding.create_project.steps_navigation.project_description correctly pulls this up from spec/dummy/config/locales/views/onboarding/create_project.yml
    context 'when the step does not have a locale entry' do
      let(:step) { tested_first_step }

      it 'humanizes the step name' do
        expect(subject).to eq tested_first_step.to_s.humanize
      end
    end
  end

  describe '#step_icon(step)' do
    subject { high_level_navigation_bar_presenter.step_icon(step) }
    context 'when the step is the last step' do
      let(:step) { tested_last_step }
      it 'returns the icon string' do
        expect(subject).to eq 'check'
      end
    end

    context 'when the step is not the last step' do
      let(:step) { tested_first_step }
      it 'returns nil so as to disable the icon via the component options' do
        expect(subject).to eq nil
      end
    end
  end

  describe '#step_status(step)' do
    subject { high_level_navigation_bar_presenter.step_status(step) }
    context 'when step is the active step' do
      let(:step) { current_step }
      it { is_expected.to eq :active }
    end

    context 'when step has been completed' do
      let(:current_step) { tested_last_step }
      let(:step) { tested_first_step }
      before { allow(onboarding_session).to receive(:completed_steps).and_return([step]) }
      it 'is determined to be visited' do
        expect(subject).to eq :visited
      end
    end

    context 'when step has not yet been visited' do
      let(:current_step) { tested_first_step }
      let(:step) { tested_last_step }
      it 'returns a status conducive to being visited' do
        expect(subject).to eq :disabled
      end
    end
  end
end