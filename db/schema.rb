# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_28_132007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.string "pickup_location"
    t.string "dropoff_location"
    t.decimal "pickup_lat"
    t.decimal "pickup_lng"
    t.decimal "dropoff_lat"
    t.decimal "dropoff_lng"
    t.decimal "distance"
    t.integer "duration"
    t.integer "passengers"
    t.text "pickup_note"
    t.string "status"
    t.string "payment_status"
    t.string "payment_method"
    t.bigint "user_id", null: false
    t.bigint "driver_id", null: false
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_bookings_on_driver_id"
    t.index ["tenant_id"], name: "index_bookings_on_tenant_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "status"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_drivers_on_tenant_id"
    t.index ["user_id"], name: "index_drivers_on_user_id"
    t.index ["vehicle_id"], name: "index_drivers_on_vehicle_id"
  end

  create_table "guest_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_guest_users_on_tenant_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.decimal "amount"
    t.string "payment_method"
    t.string "transaction_id"
    t.string "status"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["tenant_id"], name: "index_payments_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "model"
    t.string "make"
    t.string "year"
    t.string "license_plate"
    t.integer "capacity"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_vehicles_on_tenant_id"
  end

  add_foreign_key "bookings", "drivers"
  add_foreign_key "bookings", "tenants"
  add_foreign_key "bookings", "users"
  add_foreign_key "drivers", "tenants"
  add_foreign_key "drivers", "users"
  add_foreign_key "drivers", "vehicles"
  add_foreign_key "guest_users", "tenants"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "tenants"
  add_foreign_key "users", "tenants"
  add_foreign_key "vehicles", "tenants"
end
