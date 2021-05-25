require 'rails_helper'

RSpec.describe 'onboarding/nfg_ui/_sub_layout.html.haml', type: :view do

  # Locals
  let(:show_exit_button) { nil }
  let(:guidance) { '' }
  let(:header_message) { '' }
  let(:header_page) { '' }
  let(:enable_next_button) { nil }
  let(:next_step_confirmation) { nil }
  let(:back_button_text) { nil }
  let(:submit_button_text) { nil }
  let(:framed) { nil }
  let(:hide_navigation_bar) { true }

  # View spec setup
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }
  let(:step) { :first }
  let(:form) { NfgOnboarder::InformationalForm.new(OpenStruct.new(name: '')) }
  let(:wizard_path) { '/test/path' }

  subject { render layout: 'onboarding/nfg_ui/sub_layout', locals: {
    show_exit_button: show_exit_button,
    guidance: guidance,
    header_message: header_message,
    header_page: header_page,
    enable_next_button: enable_next_button,
    next_step_confirmation: next_step_confirmation,
    back_button_text: back_button_text,
    submit_button_text: submit_button_text,
    framed: framed,
    hide_navigation_bar: hide_navigation_bar
   } }

   before do
     allow(view).to receive(:locale_namespace).and_return(locale_namespace)
     allow(view).to receive(:step).and_return(step)
     allow(view).to receive(:form).and_return(form)
     allow(view).to receive(:wizard_path).and_return(wizard_path)
     allow(view).to receive(:onboarding_session).and_return(nil)
     allow(view).to receive(:exit_without_saving?).and_return(false)
     allow(view).to receive(:first_step).and_return(false)
   end

   pending 'coming soon -- cannot yet stub the `form` object'
end
