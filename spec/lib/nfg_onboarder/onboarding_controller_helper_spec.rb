require 'rails_helper'

class FakesController < ApplicationController
  include NfgOnboarder::OnboardingControllerHelper
end

describe FakesController do
  let(:form) { double('form', model: model, build_errors: nil, validate: true, save: nil) }
  let(:model) { double('model', name: '', persisted?: true) }
  let(:onboarding_session) { double('onboarding_session', step_data: {}, onboarder_progress: {},
                                    'current_high_level_step=' => nil, 'current_step=' => nil, 'owner=' => nil,
                                    'completed_high_level_steps' => []) }

  let(:params) { double('params', fetch: double('fetch', permit!: true)) }

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
  end

  it "should set the owner" do
    expect(onboarding_session).to receive(:owner=).with(model)
    expect(onboarding_session).to receive(:save)
    subject.update
  end
end
