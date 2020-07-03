class AddTypeLatLongIndexToHeatmapPoint < ActiveRecord::Migration[5.2]
  def up
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_and_lat"
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_and_long"
    add_index :heatmap_points, [:transit_type, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
    add_index :heatmap_points, [:transit_type, :precision, :long], name: "index_heatmap_points_on_type_and_long"
    add_index :heatmap_points, [:transit_type, :lat, :long], name: "index_heatmap_points_on_type_lat_long"
  end

  def down
    remove_index :heatmap_points, [:transit_type, :lat, :long], name: "index_heatmap_points_on_type_lat_long"
    remove_index :heatmap_points, [:transit_type, :precision, :long], name: "index_heatmap_points_on_type_and_long"
    remove_index :heatmap_points, [:transit_type, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
    add_index :heatmap_points, [:transit_type, :quality, :precision, :long], name: "index_heatmap_points_on_type_and_long"
    add_index :heatmap_points, [:transit_type, :quality, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
  end
end
