class AddBoundsToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :build_heatmap_statuses, :south_west, :integer, array: true
    add_column :build_heatmap_statuses, :north_east, :integer, array: true
    add_column :build_heatmap_statuses, :transit_type_low, :integer
    add_column :build_heatmap_statuses, :transit_type_high, :integer
  end
end
