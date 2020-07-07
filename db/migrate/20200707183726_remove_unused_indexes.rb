class RemoveUnusedIndexes < ActiveRecord::Migration[5.2]
  def up
    remove_index :heatmap_points, name: "index_heatmap_points_on_lat"
    remove_index :heatmap_points, name: "index_heatmap_points_on_long"
    remove_index :heatmap_points, name: "index_heatmap_points_on_precision_and_lat"
    remove_index :heatmap_points, name: "index_heatmap_points_on_precision_and_long"
  end
  def down
    add_index :heatmap_points, [:lat], name: "index_heatmap_points_on_lat"
    add_index :heatmap_points, [:long], name: "index_heatmap_points_on_long"
    add_index :heatmap_points, [:precision, :lat], name: "index_heatmap_points_on_precision_and_lat"
    add_index :heatmap_points, [:precision, :long], name: "index_heatmap_points_on_precision_and_long"
  end
end
