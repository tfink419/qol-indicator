class RenamePolygonToGeometryInPolygons < ActiveRecord::Migration[5.2]
  def change
    rename_column :isochrone_polygons, :polygon, :geometry
    rename_column :census_tract_polygons, :polygon, :geometry
  end
end
