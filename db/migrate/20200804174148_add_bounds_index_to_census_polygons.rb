class AddBoundsIndexToCensusPolygons < ActiveRecord::Migration[5.2]
  def change
    add_index :census_tract_polygons, [:south_bound, :north_bound, :west_bound, :east_bound], name: :index_census_tract_polygons_on_bounds
  end
end
