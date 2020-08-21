class AddIndexesToPark < ActiveRecord::Migration[5.2]
  def change
    add_index :parks, :openstreetmap_id, unique:true
    add_index :parks, [:lat, :long]
  end
end
