class ModifyBuildQualityMapTables < ActiveRecord::Migration[5.2]
  def up
    add_column :build_quality_map_statuses, :current_lat_sector, :integer
    add_column :build_quality_map_segment_statuses, :current_lat_sector, :integer
    change_column :build_quality_map_statuses, :south_west, :float, array: true
    change_column :build_quality_map_statuses, :north_east, :float, array: true
    remove_column :build_quality_map_statuses, :rebuild
    change_column :scheduled_point_rebuilds, :south_bounds, :float, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :west_bounds, :float, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :north_bounds, :float, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :east_bounds, :float, default: [], null: false, array: true
  end

  def down
    change_column :scheduled_point_rebuilds, :east_bounds, :integer, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :north_bounds, :integer, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :west_bounds, :integer, default: [], null: false, array: true
    change_column :scheduled_point_rebuilds, :south_bounds, :integer, default: [], null: false, array: true
    add_column :build_quality_map_statuses, :rebuild, :boolean
    change_column :build_quality_map_statuses, :north_east, :integer, array: true
    change_column :build_quality_map_statuses, :south_west, :integer, array: true
    remove_column :build_quality_map_segment_statuses, :current_lat_sector
    remove_column :build_quality_map_statuses, :current_lat_sector
  end
end