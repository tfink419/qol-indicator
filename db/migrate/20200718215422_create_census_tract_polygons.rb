class CreateCensusTractPolygons < ActiveRecord::Migration[5.2]
  def change
    create_table :census_tract_polygons do |t|
      t.integer :census_tract_id, null: false
      t.float :south_bound, null: false
      t.float :north_bound, null: false
      t.float :west_bound, null: false
      t.float :east_bound, null: false
      t.text :polygon, array: true
      t.timestamps
    end
    add_index :census_tract_polygons, :census_tract_id, unique:true
  end
end
