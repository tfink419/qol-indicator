class AddTypeLatLongIndexToHeatmapPoint < ActiveRecord::Migration[5.2]
  def change
    remove_index :heatmap_points, "index_heatmap_points_on_type_and_lat"
    remove_index :heatmap_points, "index_heatmap_points_on_type_and_long"
    add_index :heatmap_points, [:transit_type, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
    add_index :heatmap_points, [:transit_type, :precision, :long], name: "index_heatmap_points_on_type_and_long"
    add_index :heatmap_points, [:transit_type, :lat, :long], name: "index_heatmap_points_on_type_lat_long"
  end
end
