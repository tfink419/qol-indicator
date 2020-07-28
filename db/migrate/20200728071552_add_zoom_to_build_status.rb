class AddZoomToBuildStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :build_quality_map_statuses, :current_zoom, :integer
    add_column :build_quality_map_segment_statuses, :current_zoom, :integer
  end
end
