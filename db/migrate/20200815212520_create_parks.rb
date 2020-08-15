class CreateParks < ActiveRecord::Migration[5.2]
  def change
    create_table :parks do |t|
      t.integer :openstreetmap_id
      t.text :name
      t.json :nodes
      t.integer :num_activities, default: 10
      t.float :lat
      t.float :long
    end
  end
end
