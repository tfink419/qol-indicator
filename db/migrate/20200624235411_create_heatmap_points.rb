class CreateHeatmapPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :heatmap_points do |t|
      t.integer :transit_type, nil: false
      t.integer :precision, nil: false
      t.float :lat, nil: false
      t.float :long, nil: false
      t.float :quality, nil: false
      t.timestamps
    end
    add_index :heatmap_points, :lat
    add_index :heatmap_points, :long
    add_index :heatmap_points, [:precision, :lat]
    add_index :heatmap_points, [:precision, :long]
    add_index :heatmap_points, [:transit_type, :quality, :precision, :lat], name: "index_heatmap_points_on_type_and_lat"
    add_index :heatmap_points, [:transit_type, :quality, :precision, :long], name: "index_heatmap_points_on_type_and_long"
  end
end
