# frozen_string_literal: true

module Onboarding
  class Session < NfgOnboarder::Session
    belongs_to :entity, class_name: 'Project'
  end
end
