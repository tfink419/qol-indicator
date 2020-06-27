class CreateIsochronePolygons < ActiveRecord::Migration[5.2]
  def change
    create_table :isochrone_polygons do |t|
      t.references :isochronable, polymorphic: true, index: { name: 'index_iso_polys_on_poly_assoc' }
      t.string :travel_type, nil: false
      t.integer :distance, nil: false
      t.text :polygon, array: true, nil: false
      t.timestamps
    end
    add_index :isochrone_polygons, [:isochronable_id, :travel_type], name: "index_iso_polys_on_travel_type_and_belongs_id"
    #Ex:- add_index("admin_users", "username")
  end
end
