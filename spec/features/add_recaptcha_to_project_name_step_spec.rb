require "rails_helper"

RSpec.describe "When recaptcha is required on the project name step", js: true do
  before do
    allow_any_instance_of(Onboarding::CreateProjectController).to receive(:use_recaptcha?).and_return(true)
    allow_any_instance_of(Onboarding::CreateProjectController).to receive(:verify_recaptcha).and_return(verify_recaptcha)
  end

  let(:project_name) { "My first project" }
  let(:project_description) { 'My description' }
  let(:project) { Project.last }
  let(:session) { NfgOnboarder::Session.last }

  context 'and the user does not validate recapthcha correctly' do
    let(:verify_recaptcha) { false }

    it 'returns the user to the project name step with an error' do
      visit onboarding_create_project_index_path
      page.find('#onboarding_create_project_project_name_name', wait: 5)

      and_by "filling in the name field and clicking next" do
        fill_in "Project Name", with: project_name

        # treats it like any other validation error and does not
        # create the underlying objects
        expect do
          click_onboarding_next_button(:create_project, :project_name)
          page.find('#onboarding_create_project_project_name_name', wait: 5)
        end.to change(Project, :count).by(0).
          and change(NfgOnboarder::Session, :count).by(0)

        expect(page).to have_content("There was an error in your submission")

        # should return an error and redisplay the page.
        expect(current_path).to eq(onboarding_create_project_path(id: :project_name))
      end
    end
  end

  context 'and the user does validate recapthcha correctly' do
    let(:verify_recaptcha) { true }

    it 'take the user to the the next step' do
      visit onboarding_create_project_index_path
      page.find('#onboarding_create_project_project_name_name', wait: 5)

      and_by "filling in the name field and clicking next" do
        fill_in "Project Name", with: project_name

        expect do
          click_onboarding_next_button(:create_project, :project_name)
          page.find('#onboarding_create_project_project_description_description', wait: 5)
        end.to change(Project, :count).by(1).
          and change(NfgOnboarder::Session, :count).by(1)

        expect(project.reload.name).to eq(project_name)
        # should return an error and redisplay the page.
        expect(current_path).to eq(onboarding_create_project_path(id: :project_description))
      end
    end
  end
end
