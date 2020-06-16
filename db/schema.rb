# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_15_231659) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "grocery_stores", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "address", limit: 100
    t.string "city", limit: 100
    t.string "state", limit: 50
    t.integer "zip"
    t.float "lat", null: false
    t.float "long", null: false
    t.integer "quality", default: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lat"], name: "index_grocery_stores_on_lat"
    t.index ["long"], name: "index_grocery_stores_on_long"
  end

  create_table "map_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "transit_type", default: 2
    t.index ["user_id"], name: "index_map_preferences_on_user_id"
  end

  create_table "password_resets", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.datetime "expires_at"
    t.index ["expires_at"], name: "index_password_resets_on_expires_at"
    t.index ["uuid"], name: "index_password_resets_on_uuid"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.string "username", limit: 50
    t.string "email", null: false
    t.string "password_digest"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["username"], name: "index_users_on_username"
  end

end
