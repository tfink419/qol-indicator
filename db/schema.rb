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

ActiveRecord::Schema.define(version: 2020_08_03_155650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "build_quality_map_segment_statuses", force: :cascade do |t|
    t.integer "build_quality_map_status_id"
    t.float "percent"
    t.string "state"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "segment"
    t.float "current_lat"
    t.integer "current_lat_sector"
    t.integer "current_zoom"
  end

  create_table "build_quality_map_statuses", force: :cascade do |t|
    t.float "percent"
    t.string "state"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "current_lat"
    t.float "south_west", array: true
    t.float "north_east", array: true
    t.integer "transit_type_low"
    t.integer "transit_type_high"
    t.string "point_type"
    t.integer "current_lat_sector"
    t.integer "current_zoom"
  end

  create_table "census_tract_polygons", force: :cascade do |t|
    t.integer "census_tract_id", null: false
    t.float "south_bound", null: false
    t.float "north_bound", null: false
    t.float "west_bound", null: false
    t.float "east_bound", null: false
    t.json "geometry", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["census_tract_id"], name: "index_census_tract_polygons_on_census_tract_id", unique: true
  end

  create_table "census_tracts", force: :cascade do |t|
    t.string "geoid", null: false
    t.float "poverty_percent", null: false
    t.float "land_area", null: false
    t.integer "population", null: false
    t.float "population_density", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geoid"], name: "index_census_tracts_on_geoid", unique: true
  end

  create_table "grocery_store_upload_statuses", force: :cascade do |t|
    t.float "percent"
    t.string "state"
    t.string "message"
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
    t.integer "food_quantity", default: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_place_id"
    t.string "tags", default: [], array: true
    t.index ["google_place_id"], name: "index_grocery_stores_on_google_place_id", unique: true
    t.index ["lat", "long"], name: "index_grocery_stores_on_lat_and_long"
    t.index ["long"], name: "index_grocery_stores_on_long"
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
    t.json "geometry", null: false
    t.index ["isochronable_type", "isochronable_id", "travel_type"], name: "index_iso_polys_on_poly_assoc_and_travel_type"
    t.index ["isochronable_type", "travel_type", "distance", "south_bound", "north_bound", "west_bound", "east_bound"], name: "index_isochrone_polygons_on_bounds_and_type"
  end

  create_table "map_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "grocery_store_transit_type", default: 2
    t.integer "census_tract_poverty_low", default: 5
    t.integer "census_tract_poverty_high", default: 40
    t.integer "census_tract_poverty_ratio", default: 50
    t.integer "grocery_store_ratio", default: 50
    t.integer "grocery_store_tags", default: 1
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
    t.float "south_bounds", default: [], null: false, array: true
    t.float "west_bounds", default: [], null: false, array: true
    t.float "north_bounds", default: [], null: false, array: true
    t.float "east_bounds", default: [], null: false, array: true
    t.string "point_type"
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
