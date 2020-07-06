class MakeBoundsNotNullInIsochronePolygons < ActiveRecord::Migration[5.2]
  def up
    change_column :isochrone_polygons, :south_bound, :float, null: false
    change_column :isochrone_polygons, :north_bound, :float, null: false
    change_column :isochrone_polygons, :west_bound, :float, null: false
    change_column :isochrone_polygons, :east_bound, :float, null: false
  end

  def down
    change_column :isochrone_polygons, :east_bound, :float
    change_column :isochrone_polygons, :west_bound, :float
    change_column :isochrone_polygons, :north_bound, :float
    change_column :isochrone_polygons, :south_bound, :float
  end
end
