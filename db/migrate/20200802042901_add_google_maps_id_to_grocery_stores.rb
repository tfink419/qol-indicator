class AddGoogleMapsIdToGroceryStores < ActiveRecord::Migration[5.2]
  def change
    add_column :grocery_stores, :google_place_id, :string
    add_index :grocery_stores, :google_place_id, unique: true
    remove_column :grocery_stores, :organic, :boolean, default: false
    add_column :grocery_stores, :tags, :string, array: true, default:[]
  end
end
