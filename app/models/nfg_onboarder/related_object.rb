class NfgOnboarder::RelatedObject < ActiveRecord::Base
  self.table_name = 'onboarding_related_objects'

  belongs_to :onboarding_session, class_name: 'NfgOnboarder::Session', optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates :name, uniqueness: { scope: :onboarding_session_id }

  after_destroy :destroy_related_onboarding_session

  private

  def destroy_related_onboarding_session
    self.onboarding_session.destroy if onboarding_session
  end
end
