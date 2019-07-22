# This is just for testing the onboarder module for the dummy app
class CreateTesting < ActiveRecord::Migration[5.2]
  def change
    create_table :testings do |t|
    end
  end
end
