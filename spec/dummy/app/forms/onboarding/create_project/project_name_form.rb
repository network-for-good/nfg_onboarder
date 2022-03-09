# frozen_string_literal: true

module Onboarding
  module CreateProject
    class ProjectNameForm < Onboarding::CreateProject::BaseForm
      ## Add properties for your form below:
      property :name

      validates :name, presence: true
    end
  end
end
