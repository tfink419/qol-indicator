class AddIndexesToPark < ActiveRecord::Migration[5.2]
  def change
    add_index :parks, :openstreetmap_id
    add_index :parks, [:lat, :long]
  end
end
