class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
