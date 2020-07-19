class ReorderHeatmapPointIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_prec_lat_long"
    add_index :heatmap_points, [:transit_type, :lat, :long, :precision], name: "index_heatmap_points_on_type_lat_long_prec", unique:true
  end
  def down
    remove_index :heatmap_points, name: "index_heatmap_points_on_type_lat_long_prec"
    add_index :heatmap_points, [:transit_type, :precision, :lat, :long], name: "index_heatmap_points_on_type_prec_lat_long", unique:true
  end
end
