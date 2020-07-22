class ChangeGeometryColumnsToString < ActiveRecord::Migration[5.2]
  def up
    change_column :isochrone_polygons, :geometry, :string, null: false
    change_column :census_tract_polygons, :geometry, :string, null: false
  end
  def down
    change_column :census_tract_polygons, :geometry, :string, array: true
    change_column :isochrone_polygons, :geometry, :string, array: true
  end
end
