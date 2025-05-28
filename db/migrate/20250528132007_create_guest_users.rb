class CreateGuestUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :guest_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
