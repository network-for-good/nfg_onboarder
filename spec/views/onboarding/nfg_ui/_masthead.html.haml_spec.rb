require 'rails_helper'

RSpec.describe 'onboarding/nfg_ui/_masthead.html.haml', type: :view do
  let(:show_exit_button) { nil }
  let(:render_title) { nil }
  let(:exit_path) { nil }
  let(:first_step) { nil }
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }

  subject { render partial: 'onboarding/nfg_ui/masthead', locals: { show_exit_button: show_exit_button, render_title: render_title, exit_path: exit_path, locale_namespace: locale_namespace } }

  before do
    allow(view).to receive(:first_step).and_return(first_step)
  end

  describe 'the title' do
    context 'when render_title is true via local_assigns' do
      let(:render_title) { true }
      it 'renders the title' do
        expect(subject).to have_css "h6", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end

    context 'when render_title is false via local_assigns' do
      let(:render_title) { false }
      it 'does not render the title' do
        expect(subject).not_to have_css "h6", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end

    context 'when render_title is nil via local_assigns' do
      let(:render_title) { nil }
      it 'renders the title via the fallback set in the partial for render_title when local assigns is nil' do
        expect(subject).to have_css "h6", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end
  end
end