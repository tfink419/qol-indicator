class AugmentIndexesForLatAndLong < ActiveRecord::Migration[5.2]
  def up
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_and_long"
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_and_lat"
    remove_index :grocery_stores, :lat
    add_index :heatmap_points, [:transit_type, :precision, :lat, :long], name: "index_heatmap_points_on_type_prec_lat_long", unique:true
    add_index :grocery_stores, [:lat, :long]
  end
  def down
    remove_index :grocery_stores, [:lat, :long]
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_prec_lat_long"
    add_index :grocery_stores, :lat
    add_index :heatmap_points, [:transit_type, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
    add_index :heatmap_points, [:transit_type, :precision, :long], name: "index_heatmap_points_on_type_and_long"
  end
end
