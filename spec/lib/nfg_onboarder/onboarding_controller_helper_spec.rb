require 'rails_helper'

class FakesController < ApplicationController
  include NfgOnboarder::OnboardingControllerHelper

  def finish_wizard_path
    'abc'
  end
end

describe FakesController do
  let(:form) { double('form', model: model, build_errors: nil, validate: true, save: nil) }
  let(:model) { double('model', name: '', persisted?: true, onboarding_sessions: onboarding_sessions) }
  let(:onboarding_session) do
    FactoryBot.create(
      :onboarding_session,
      step_data: {},
      onboarder_progress: {},
      current_high_level_step: nil,
      current_step: step,
      owner: nil,
      completed_high_level_steps: nil
    )
  end
  let(:params) do
    double('params', fetch: double('fetch', permit!: true), keys: keys, select: double('select', permit!: nil))
  end
  let(:onboarding_sessions) { double('onboarding_sessions', is_a?: activerecord_proxy) }
  let(:activerecord_proxy) { true }
  let(:exit) { false }
  let(:step) { 'some-step' }
  let(:high_level_step) { nil }

  let(:keys) { [] }
  before do
    allow_any_instance_of(FakesController).to receive(:get_onboarding_session).and_return(onboarding_session)
    allow_any_instance_of(FakesController).to receive(:params).and_return(params)
    allow_any_instance_of(FakesController).to receive(:step).and_return(step)
    allow_any_instance_of(FakesController).to receive(:steps).and_return([step])
    allow_any_instance_of(FakesController).to receive(:onboarding_group_steps).and_return(high_level_step)
    allow_any_instance_of(FakesController).to receive(:next_step).and_return('next-step')
    allow_any_instance_of(FakesController).to receive(:cleansed_param_data)
    allow_any_instance_of(FakesController).to receive(:get_form_object).and_return(form)
    allow_any_instance_of(FakesController).to receive(:jump_to)
    allow_any_instance_of(FakesController).to receive(:render_wizard)
    allow_any_instance_of(FakesController).to receive(:performed?).and_return(false)
    allow_any_instance_of(FakesController).to receive(:performed?).and_return(false)
    allow_any_instance_of(ApplicationController).to receive(:redirect_to).and_return(double('redirect'))

    allow(params).to receive(:[]).with(:exit).and_return(exit)
  end

  context 'when event target is present' do
    context 'when event target is a ActiveRecord associations collection proxy' do
      it 'should set the owner' do
        expect(onboarding_session).to receive(:owner=).with(model)
        expect(onboarding_session).to receive(:save)
        subject.update
      end

      context 'when the exit param is defined' do
        let(:exit) { true }

        context 'when the step doesnt require saving' do
          before { allow_any_instance_of(FakesController).to receive(:exit_without_save_steps).and_return([step]) }

          it 'should not set the owner' do
            expect(onboarding_session).to_not receive(:owner=).with(model)
            expect(onboarding_session).to_not receive(:save)
            subject.update
          end
        end

        context 'when the step requires saving' do
          it 'should set the owner' do
            expect(onboarding_session).to receive(:owner=).with(model)
            expect(onboarding_session).to receive(:save)
            subject.update
          end
        end
      end

      context 'when group_steps are present' do
        let(:high_level_step) { 'some-high-level-step' }

        before do
          allow_any_instance_of(ApplicationController).to receive(:finish_wizard_path).and_return('abc')
        end

        it 'should set the owner' do
          expect(onboarding_session).to receive(:owner=).with(model)
          expect(onboarding_session).to receive(:save)
          subject.update
        end
      end
    end

    context 'when event target is not a ActiveRecord associations collection proxy' do
      let(:activerecord_proxy) { false }

      it 'should not set the owner' do
        expect(onboarding_session).not_to receive(:owner=).with(model)
        subject.update
      end

      context 'when there is an ALT_FINISH_PATH_PREPEND_KEY present' do
        let(:keys) { ["#{NfgOnboarder::OnboardingControllerHelper::ALT_FINISH_PATH_PREPEND_KEY}_/imports/1"] }
        before { allow_any_instance_of(FakesController).to receive(:last_step).and_return(last_step) }

        context 'when it is the last step' do
          let(:last_step) { true }
          it 'should merge the right key with the params' do
            expect(params).to receive(:merge!).with({ NfgOnboarder::OnboardingControllerHelper::ALT_FINISH_PATH_PREPEND_KEY => '/imports/1' })
            subject.update
          end

          context 'when the alt finish wizard path key is not present' do
            let(:keys) { [] }
            it 'should not merge the right key with the params' do
              expect(params).to_not receive(:merge!).with({ NfgOnboarder::OnboardingControllerHelper::ALT_FINISH_PATH_PREPEND_KEY => '/imports/1' })
              subject.update
            end
          end
        end

        context 'when it is not the last step' do
          let(:last_step) { false }
          it 'should not merge the right key with the params' do
            expect(params).to_not receive(:merge!).with({ NfgOnboarder::OnboardingControllerHelper::ALT_FINISH_PATH_PREPEND_KEY => '/imports/1' })
            subject.update
          end
        end

      end
    end
  end

  context 'when event target is not present' do
    before { allow_any_instance_of(FakesController).to receive(:get_form_object).and_return(form) }

    it 'should not set onboarding session name' do
      expect(onboarding_session).to_not receive(:name=)
    end
  end
end
