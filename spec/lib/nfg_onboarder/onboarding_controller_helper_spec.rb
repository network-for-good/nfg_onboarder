require 'rails_helper'

class FakesController < ApplicationController
  include NfgOnboarder::OnboardingControllerHelper
end

describe FakesController do
  let(:form) { double('form', model: model, build_errors: nil, validate: true, save: nil) }
  let(:model) { double('model', name: '', persisted?: true, onboarding_sessions: onboarding_sessions) }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session, step_data: {}, onboarder_progress: {}, current_high_level_step: nil, current_step: nil, owner: nil, completed_high_level_steps: nil) }
  let(:params) { double('params', fetch: double('fetch', permit!: true)) }
  let(:onboarding_sessions) { double('onboarding_sessions', is_a?: activerecord_proxy) }
  let(:activerecord_proxy) { true }

  before do
    allow_any_instance_of(FakesController).to receive(:get_onboarding_session).and_return(onboarding_session)
    allow_any_instance_of(FakesController).to receive(:params).and_return(params)
    allow_any_instance_of(FakesController).to receive(:step).and_return('some-step')
    allow_any_instance_of(FakesController).to receive(:steps).and_return(['some-step'])
    allow_any_instance_of(FakesController).to receive(:next_step).and_return('next-step')
    allow_any_instance_of(FakesController).to receive(:cleansed_param_data)
    allow_any_instance_of(FakesController).to receive(:get_form_object).and_return(form)
    allow_any_instance_of(FakesController).to receive(:jump_to)
    allow_any_instance_of(FakesController).to receive(:render_wizard)
    allow_any_instance_of(FakesController).to receive(:performed?).and_return(false)
    allow_any_instance_of(FakesController).to receive(:performed?).and_return(false)
  end

  context 'when event target is present' do
    context 'when event target is a ActiveRecord associations collection proxy' do
      it 'should set the owner' do
        expect(onboarding_session).to receive(:owner=).with(model)
        expect(onboarding_session).to receive(:save)
        subject.update
      end
    end

    context 'when event target is not a ActiveRecord associations collection proxy' do
      let(:activerecord_proxy) { false }

      it 'should not set the owner' do
        expect(onboarding_session).not_to receive(:owner=).with(model)
        subject
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
