require 'rails_helper'

describe NfgOnboarder::RelatedObject do
  it { should validate_uniqueness_of(:name).scoped_to(:onboarding_session_id) }
end
