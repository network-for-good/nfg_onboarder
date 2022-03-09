# frozen_string_literal: true

module NfgOnboarder
  module OnboardableObject
    extend ActiveSupport::Concern

    included do
      has_many :related_objects, as: :target, class_name: 'Onboarding::RelatedObject', dependent: :destroy
    end
  end
end
