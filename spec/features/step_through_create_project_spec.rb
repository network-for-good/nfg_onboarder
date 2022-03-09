require "rails_helper"

RSpec.describe "Walking through the create project onboarder", js: true do
  let(:project_name) { "My first project" }
  let(:project_description) { 'My description' }
  let(:project) { Project.last }
  let(:session) { NfgOnboarder::Session.last }

  it 'allows the user to enter one piece of information at a time to create the project' do
    visit onboarding_create_project_index_path
    page.find('#onboarding_create_project_project_name_name', wait: 5)

    and_by "leaving the name field blank and clicking on the button to go to the next step it returns you to the project name page with an error" do
      # does not create the underlying object, or the onboarding session
      expect do
        click_onboarding_next_button(:create_project, :project_name)
      end.to change(Project, :count).by(0).
        and change(NfgOnboarder::Session, :count).by(0)
      # should return an error and redisplay the page.
      expect(current_path).to eq(onboarding_create_project_path(id: :project_name))
      expect(page).to have_content("There was an error in your submission")
    end

    and_by "filling in the name field and clicking next, will go to the description field" do
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

    and_by "filling in the description field and submiting" do
      # it updates the project and redirects to googles home page

      fill_in "Project Description", with: project_description

      expect do
        click_onboarding_next_button(:create_project, :project_description)
        sleep 1
      end.to change(Project, :count).by(0).
        and change(NfgOnboarder::Session, :count).by(0)

      expect(project.reload.description).to eq(project_description)
      expect(session.completed_at).not_to be_nil

      # takes user to the finish_wizard_path
      expect(current_url).to eq("https://www.google.com/?from_wicked_finish=true")
    end
  end
end