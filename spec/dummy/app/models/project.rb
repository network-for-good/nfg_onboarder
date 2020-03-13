# frozen_string_literal: true

class Project < ActiveRecord::Base
  include NfgOnboarder::OnboardableObject
  has_many :onboarding_sessions, class_name: "Onboarding::Session"
end
