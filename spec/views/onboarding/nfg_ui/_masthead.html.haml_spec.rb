require 'rails_helper'

RSpec.describe 'onboarding/nfg_ui/_masthead.html.haml', type: :view do
  let(:show_exit_button) { nil }
  let(:render_title) { nil }
  let(:exit_path) { nil }
  let(:first_step) { nil }
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session) }
  let(:locale_namespace) { ['onboarding', 'sample_onboarder'] }
  let(:h) { ActionController::Base.new.view_context }
  let(:presenter) { NfgOnboarder::MastheadPresenter.new(onboarding_session, h) }
  let(:exit_without_saving_path) { '/edit/without/saving/path' }

  subject { render partial: 'onboarding/nfg_ui/masthead', locals: { show_exit_button: show_exit_button, render_title: render_title, exit_path: exit_path, locale_namespace: locale_namespace, presenter: presenter } }

  before do
    allow(view).to receive(:first_step).and_return(first_step)
    allow(view).to receive(:onboarding_session).and_return(onboarding_session)
    allow(h).to receive(:locale_namespace).and_return(locale_namespace)
    allow(view).to receive(:exit_without_saving_path).and_return(exit_without_saving_path)
  end

  describe 'the title' do
    context 'when render_title is true via local_assigns' do
      let(:render_title) { true }
      it 'renders the title' do
        expect(subject).to have_css "h5", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end

    context 'when render_title is false via local_assigns' do
      let(:render_title) { false }
      it 'does not render the title' do
        expect(subject).not_to have_css "h5", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end

    context 'when render_title is nil via local_assigns' do
      let(:render_title) { nil }
      it 'renders the title via the fallback set in the partial for render_title when local assigns is nil' do
        expect(subject).to have_css "h5", text: I18n.t('onboarding.sample_onboarder.title_bar.title')
      end
    end
  end

  describe 'the caption' do
    it 'shows the caption' do
      expect(subject).to have_css "p", text: I18n.t('onboarding.sample_onboarder.title_bar.caption')
    end
  end

  describe 'the exit button' do
    context 'when show_exit_button is true via local_assigns variables' do
      let(:show_exit_button) { true }

      context 'when first_step is true' do
        let(:first_step) { true }
        it 'renders the first step appropriate exit button' do
          expect(subject).to have_css '#exit_button', text: I18n.t('title_bar.buttons.exit', scope: locale_namespace)

          and_it 'does not render the second+ step button' do
            expect(subject).not_to have_css '#save_and_exit'
          end
        end
      end

      context 'when first_step is false' do
        let(:first_step) { false }
        it 'renders the appropriate button' do
          expect(subject).to have_css '#save_and_exit'

          and_it 'does not render the first step button' do
            expect(subject).not_to have_css '#exit_button'
          end
        end
      end

      context 'and when the exit_path is present in locals' do
        let(:exit_path) { '/test_exit_path' }
        it 'uses the local assigned exit path as the href' do
          expect(subject).to have_css "[id*='exit'][href='#{exit_path}']"
        end
      end

      context 'and when the exit_path is nil in locals' do
        let(:exit_path) { nil }
        it 'uses the fallback href' do
          expect(subject).to have_css "[id*='exit'][href='javascript:;']"
        end
      end
    end

    context 'when show_exit_button is false via local_assigns variables' do
      let(:show_exit_button) { false }

      it 'does not render an exit button' do
        expect(subject).not_to have_css '#save_and_exit'
        expect(subject).not_to have_css '#exit_button'
      end
    end

    context 'when show_exit_button is nil in local_assigns variables' do
      let(:show_exit_button) { nil }
      it 'defaults to true' do
        expect(subject).to have_css '#save_and_exit'
      end
    end
  end
end