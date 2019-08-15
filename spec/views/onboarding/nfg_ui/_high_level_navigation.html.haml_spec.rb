require 'rails_helper'
require 'wicked'


RSpec.describe 'onboarding/nfg_ui/_high_level_navigation.html.haml', type: :view do
  # Locals
  let(:next_step_confirmation) { nil }
  let(:disable_next_button) { nil }
  let(:back_button_text) { '' }
  let(:submit_button_text) { '' }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session) }
  let(:presenter) { NfgOnboarder::HighLevelNavigationBarPresenter.new(onboarding_session, h) }

  # View spec setup
  let(:h) { ActionController::Base.new.view_context }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step) }
  let(:first_step) { :first }
  let(:last_step) { :last }
  let(:steps) { [first_step, :second, last_step] }
  let(:current_step) { first_step }
  let(:wizard_path) { '/test_path' }
  let(:before_point_of_no_return) { false }
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }

  before do
    # allow(presenter).to receive_message_chain(h.params).and_return(id: current_step)
    allow(h.controller).to receive(:params).and_return(id: current_step)
    allow(controller).to receive(:wizard_steps).and_return(steps)
    allow(h.controller).to receive(:wizard_steps).and_return(steps)
    allow(view).to receive(:onboarding_session).and_return(onboarding_session)
    allow(view).to receive(:wizard_path).and_return(wizard_path)

    allow(h).to receive(:before_last_visited_point_of_no_return?).and_return(before_point_of_no_return)
    allow(view).to receive(:locale_namespace).and_return(locale_namespace)
    allow(view).to receive(:previous_wizard_path).and_return(wizard_path)
    allow(view).to receive(:first_step).and_return(first_step)
  end

  subject { render partial: 'onboarding/nfg_ui/high_level_navigation', locals: { next_step_confirmation: next_step_confirmation, disable_next_button: disable_next_button, back_button_text: back_button_text, submit_button_text: submit_button_text, presenter: presenter } }

end