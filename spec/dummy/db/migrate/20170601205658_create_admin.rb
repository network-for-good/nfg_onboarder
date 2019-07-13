class CreateAdmin < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
    end
  end
end
