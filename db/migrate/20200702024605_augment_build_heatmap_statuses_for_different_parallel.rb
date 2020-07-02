class AugmentBuildHeatmapStatusesForDifferentParallel < ActiveRecord::Migration[5.2]
  def up
    add_column :build_heatmap_segment_statuses, :current_lat, :float
    add_column :build_heatmap_statuses, :current_lat, :float
    add_column :build_heatmap_statuses, :rebuild, :boolean
  end

  def down
    remove_column :build_heatmap_statuses, :rebuild
    remove_column :build_heatmap_statuses, :current_lat
    remove_column :build_heatmap_segment_statuses, :current_lat
  end
end
