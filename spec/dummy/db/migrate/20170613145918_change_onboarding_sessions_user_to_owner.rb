class ChangeOnboardingSessionsUserToOwner < ActiveRecord::Migration[5.0]
  def change
    rename_column :onboarding_sessions, :user_id, :owner_id
    rename_column :onboarding_sessions, :user_type, :owner_type
  end
end
