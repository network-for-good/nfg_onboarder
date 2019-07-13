# for dummy testing in dummy app
# this is just a class to test onboardable owner concern
# this is only included in the dummy app
class Testing < ActiveRecord::Base
  include NfgOnboarder::OnboardableOwner
end
