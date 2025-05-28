class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :model
      t.string :make
      t.string :year
      t.string :license_plate
      t.integer :capacity
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
