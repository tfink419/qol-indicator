class DropMapPointTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :grocery_store_quality_map_points
    drop_table :census_tract_poverty_map_points
  end
  def down
    create_table "census_tract_poverty_map_points", force: :cascade do |t|
      t.integer "precision", null: false
      t.integer "lat", null: false
      t.integer "long", null: false
      t.float "value", null: false
      t.index ["lat", "long", "precision"], name: "index_census_tract_poverty_points_on_lat_long_prec", unique: true
    end
    create_table "grocery_store_quality_map_points", force: :cascade do |t|
      t.integer "transit_type", null: false
      t.integer "precision", null: false
      t.integer "lat", null: false
      t.integer "long", null: false
      t.float "value", null: false
      t.index ["transit_type", "lat", "long", "precision"], name: "index_grocery_store_quality_points_on_type_lat_long_prec", unique: true
      t.index ["transit_type", "lat", "long"], name: "index_grocery_store_quality_points_on_type_lat_long", unique: true
    end
  end
end
