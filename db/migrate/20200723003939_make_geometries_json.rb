class MakeGeometriesJson < ActiveRecord::Migration[5.2]
  def up
    sql = 'ALTER TABLE "isochrone_polygons" ALTER COLUMN "geometry" TYPE json USING geometry::json, ALTER COLUMN "geometry" SET NOT NULL'
    ActiveRecord::Base.connection.execute(sql)
    sql = 'ALTER TABLE "census_tract_polygons" ALTER COLUMN "geometry" TYPE json USING geometry::json, ALTER COLUMN "geometry" SET NOT NULL'
    ActiveRecord::Base.connection.execute(sql)
  end
  def down
    change_column :isochrone_polygons, :geometry, :string, null: false
    change_column :census_tract_polygons, :geometry, :string, null: false
  end
end
