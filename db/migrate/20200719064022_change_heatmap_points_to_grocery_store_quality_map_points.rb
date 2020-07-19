class ChangeHeatmapPointsToGroceryStoreQualityMapPoints < ActiveRecord::Migration[5.2]
  def change
    rename_table :heatmap_points, :grocery_store_quality_map_points
    rename_table :build_heatmap_segment_statuses, :build_quality_map_segment_statuses
    rename_table :build_heatmap_statuses, :build_quality_map_statuses
    rename_index :grocery_store_quality_map_points, :index_heatmap_points_on_type_lat_long_prec, :index_grocery_store_quality_points_on_type_lat_long_prec
    rename_index :grocery_store_quality_map_points, :index_heatmap_points_on_type_lat_long, :index_grocery_store_quality_points_on_type_lat_long
    rename_column :build_quality_map_segment_statuses, :build_heatmap_status_id, :build_quality_map_status_id
  end
end
