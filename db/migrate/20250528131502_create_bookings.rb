class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.string :pickup_location
      t.string :dropoff_location
      t.decimal :pickup_lat
      t.decimal :pickup_lng
      t.decimal :dropoff_lat
      t.decimal :dropoff_lng
      t.decimal :distance
      t.integer :duration
      t.integer :passengers
      t.text :pickup_note
      t.string :status
      t.string :payment_status
      t.string :payment_method
      t.references :user, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
