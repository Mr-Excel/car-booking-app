class CreateDrivers < ActiveRecord::Migration[8.0]
  def change
    create_table :drivers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.string :status
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
