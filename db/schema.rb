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

ActiveRecord::Schema.define(version: 2020_07_14_002910) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "build_heatmap_segment_statuses", force: :cascade do |t|
    t.integer "build_heatmap_status_id"
    t.float "percent"
    t.string "state"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "segment"
    t.float "current_lat"
  end

  create_table "build_heatmap_statuses", force: :cascade do |t|
    t.float "percent"
    t.string "state"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "current_lat"
    t.boolean "rebuild"
    t.integer "south_west", array: true
    t.integer "north_east", array: true
    t.integer "transit_type_low"
    t.integer "transit_type_high"
  end

  create_table "grocery_store_upload_statuses", force: :cascade do |t|
    t.float "percent"
    t.string "state"
    t.string "message"
    t.string "filename"
    t.text "details"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.index ["lat", "long"], name: "index_grocery_stores_on_lat_and_long"
    t.index ["long"], name: "index_grocery_stores_on_long"
  end

  create_table "heatmap_points", force: :cascade do |t|
    t.integer "transit_type", null: false
    t.integer "precision", null: false
    t.integer "lat", null: false
    t.integer "long", null: false
    t.float "quality", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transit_type", "lat", "long"], name: "index_heatmap_points_on_type_lat_long", unique: true
    t.index ["transit_type", "precision", "lat", "long"], name: "index_heatmap_points_on_type_prec_lat_long", unique: true
  end

  create_table "isochrone_polygons", force: :cascade do |t|
    t.string "isochronable_type", null: false
    t.bigint "isochronable_id", null: false
    t.string "travel_type", null: false
    t.integer "distance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "south_bound", null: false
    t.float "north_bound", null: false
    t.float "west_bound", null: false
    t.float "east_bound", null: false
    t.text "polygon", array: true
    t.index ["isochronable_type", "isochronable_id", "travel_type"], name: "index_iso_polys_on_poly_assoc_and_travel_type"
    t.index ["isochronable_type", "travel_type", "distance", "south_bound", "north_bound", "west_bound", "east_bound"], name: "index_isochrone_polygons_on_bounds_and_type"
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

  create_table "scheduled_point_rebuilds", force: :cascade do |t|
    t.datetime "scheduled_time", null: false
    t.integer "south_bounds", default: [], null: false, array: true
    t.integer "west_bounds", default: [], null: false, array: true
    t.integer "north_bounds", default: [], null: false, array: true
    t.integer "east_bounds", default: [], null: false, array: true
    t.index ["scheduled_time"], name: "index_scheduled_point_rebuilds_on_scheduled_time"
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
