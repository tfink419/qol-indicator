class CreateCensusTractPovertyMapPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :census_tract_poverty_map_points do |t|
      t.integer :precision, null: false
      t.integer :lat, null: false
      t.integer :long, null: false
      t.float :poverty_percent, null: false
    end
    add_index :census_tract_poverty_map_points, [:lat, :long, :precision], name: :index_census_tract_poverty_points_on_lat_long_prec, unique: true
  end
end
