class MakeValuesNotNull < ActiveRecord::Migration[5.2]
  def up
    change_column :heatmap_points, :transit_type, :integer, null: false
    change_column :heatmap_points, :precision, :integer, null: false
    change_column :heatmap_points, :lat, :float, null: false
    change_column :heatmap_points, :long, :float, null: false
    change_column :heatmap_points, :quality, :float, null: false

    change_column :isochrone_polygons, :isochronable_type, :string, null: false
    change_column :isochrone_polygons, :isochronable_id, :bigint, null: false
    change_column :isochrone_polygons, :travel_type, :string, null: false
    change_column :isochrone_polygons, :distance, :integer, null: false
  end

  def down
    change_column :isochrone_polygons, :distance, :integer
    change_column :isochrone_polygons, :travel_type, :string
    change_column :isochrone_polygons, :isochronable_id, :bigint
    change_column :isochrone_polygons, :isochronable_type, :string

    change_column :heatmap_points, :quality, :float
    change_column :heatmap_points, :long, :float
    change_column :heatmap_points, :lat, :float
    change_column :heatmap_points, :precision, :integer
    change_column :heatmap_points, :transit_type, :integer
  end
end
