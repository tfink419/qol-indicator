class CreateCensusTracts < ActiveRecord::Migration[5.2]
  def change
    create_table :census_tracts do |t|
      t.string :geoid, null: false
      t.float :povery_percent, null: false
      t.float :land_area, null: false
      t.integer :population, null: false
      t.float :population_density, null: false
      t.timestamps
    end
    add_index :census_tracts, :geoid, unique: true
  end
end
