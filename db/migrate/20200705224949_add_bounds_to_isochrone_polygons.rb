class AddBoundsToIsochronePolygons < ActiveRecord::Migration[5.2]
  def change
    add_column :isochrone_polygons, :south_bound, :float
    add_column :isochrone_polygons, :north_bound, :float
    add_column :isochrone_polygons, :west_bound, :float
    add_column :isochrone_polygons, :east_bound, :float
    add_index :isochrone_polygons, [:isochronable_type, :travel_type, :distance, :south_bound, :north_bound, :west_bound, :east_bound], name: 'index_isochrone_polygons_on_bounds_and_type'
  end
end
