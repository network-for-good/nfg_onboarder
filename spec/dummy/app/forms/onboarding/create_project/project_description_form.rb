# frozen_string_literal: true

module Onboarding
  module CreateProject
    class ProjectDescriptionForm < Onboarding::CreateProject::BaseForm
      ## Add properties for your form below:
      property :description

      validates :description, presence: true
    end
  end
end
