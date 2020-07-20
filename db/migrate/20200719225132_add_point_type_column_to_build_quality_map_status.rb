class AddPointTypeColumnToBuildQualityMapStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :build_quality_map_statuses, :point_type, :string
    add_column :scheduled_point_rebuilds, :point_type, :string
  end
end
