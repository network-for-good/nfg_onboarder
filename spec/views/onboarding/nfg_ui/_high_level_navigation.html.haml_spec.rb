require 'rails_helper'
require 'wicked'


RSpec.describe 'onboarding/nfg_ui/_high_level_navigation.html.haml', type: :view do
  # Locals
  let(:next_step_confirmation) { nil }
  let(:disable_submit_button) { nil }
  let(:hide_submit_button) { nil }
  let(:back_button_text) { '' }
  let(:submit_button_text) { '' }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session) }
  let(:presenter) { NfgOnboarder::HighLevelNavigationBarPresenter.new(onboarding_session, h) }

  # View spec setup
  let(:h) { ActionController::Base.new.view_context }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step) }
  let(:first_step) { :first }
  let(:completed_steps) { [] }
  let(:last_step) { :last }
  let(:steps) { [first_step, :second, last_step] }
  let(:current_step) { first_step }
  let(:wizard_path) { '/test_path' }
  let(:before_point_of_no_return) { false }
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }
  let(:render_previous_button_unless) { true }

  before do
    # Both controller stubs are required:
    allow(controller).to receive(:wizard_steps).and_return(steps) # necessary for view
    allow(controller).to receive(:onboarding_group_steps).and_return(nil) # necessary for view
    allow(h.controller).to receive(:wizard_steps).and_return(steps) # necessary for presenter
    allow(h.controller).to receive(:onboarding_group_steps).and_return(nil) # necessary for view

    allow(h.controller).to receive(:params).and_return(id: current_step)
    allow(h).to receive(:locale_namespace).and_return(locale_namespace)
    allow(view).to receive(:onboarding_session).and_return(onboarding_session)
    allow(view).to receive(:wizard_path).and_return(wizard_path)
    allow(h).to receive(:before_last_visited_point_of_no_return?).and_return(before_point_of_no_return)
    allow(view).to receive(:locale_namespace).and_return(locale_namespace)
    allow(view).to receive(:previous_wizard_path).and_return(wizard_path)
    allow(view).to receive(:first_step).and_return(first_step)
    allow(presenter).to receive(:completed_steps).and_return(completed_steps)
    allow(presenter).to receive(:render_previous_button_unless?).and_return(render_previous_button_unless)
  end

  subject { render partial: 'onboarding/nfg_ui/high_level_navigation', locals: { next_step_confirmation: next_step_confirmation, disable_submit_button: disable_submit_button, hide_submit_button: hide_submit_button, back_button_text: back_button_text, submit_button_text: submit_button_text, presenter: presenter } }

  describe 'the steps in the step nav' do
    it 'lists a nav item for each step' do
      expect(subject).to have_css "[data-describe='nav-steps'] .nav-item", count: steps.size
    end

    describe 'step nav item' do
      # Put us right in the middle - step 1: completed, step 2: active, step 3: upcoming
      let(:current_step) { :second }
      let(:completed_steps) { [:first] }

      context 'an active step' do
        it 'is an active visited step' do
          expect(subject).to have_css '.nav-item.active.visited', count: 1, text: '2Second'
        end
      end

      context 'a completed step' do
        it 'is a visited ("completed") step' do
          expect(subject).to have_selector '.nav-item.visited', text: '1First'

          and_it 'is not active' do
            expect(subject).not_to have_selector '.nav-item.active.visited', text: '1First'
          end
        end
      end

      context 'an upcoming step' do
        it 'is disabled, upcoming step' do
          expect(subject).to have_selector ".nav-item.disabled[data-describe='last-step'][tabindex='-1']", text: 'Last'

          and_it 'is not active' do
            expect(subject).not_to have_selector '.nav-item.active', text: 'Last'
          end

          and_it 'is not visited' do
            expect(subject).not_to have_selector '.nav-item.visited', text: 'Last'
          end
        end
      end

      context 'the last step' do
        it 'is indicated with a checkmark' do
          expect(subject).to have_css "[data-describe='last-step'] .fa-check"
        end
      end
    end
  end

  describe 'the previous button' do
    context 'when render_previous_button_unless? is true' do
      let(:render_previous_button_unless) { true }
      it 'renders the previous button' do
        expect(subject).not_to have_css "[data-describe='previous-button']"
      end
    end

    context 'when render_previous_button_unless? is false' do
      let(:render_previous_button_unless) { false }

      it 'does not render the previous button' do
        expect(subject).to have_css "[data-describe='previous-button']"
      end
    end
  end
end