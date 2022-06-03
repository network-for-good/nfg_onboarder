class AddSaveAndExitPathToOnboardingSession < ActiveRecord::Migration[5.2]
  def change
    add_column :onboarding_sessions, :save_and_exit_path, :string
  end
end
