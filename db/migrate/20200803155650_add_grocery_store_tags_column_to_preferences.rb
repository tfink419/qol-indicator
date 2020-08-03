class AddGroceryStoreTagsColumnToPreferences < ActiveRecord::Migration[5.2]
  def change
    rename_column :map_preferences, :grocery_store_quality_transit_type, :grocery_store_transit_type
    rename_column :map_preferences, :grocery_store_quality_ratio, :grocery_store_ratio
    add_column :map_preferences, :grocery_store_tags, :integer, default: 1 # Grocery Stores, Supermarkets, and Wholesalers
  end
end
