class ChangeHeatmapPointCoordsToInteger < ActiveRecord::Migration[5.2]
  def up
    change_column :heatmap_points, :lat, :integer, null: false
    change_column :heatmap_points, :long, :integer, null: false
  end

  def down
    change_column :heatmap_points, :lat, :float, null: false
    change_column :heatmap_points, :long, :float, null: false
  end
end
