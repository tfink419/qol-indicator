class AddBooleanColumnsToGroceryStores < ActiveRecord::Migration[5.2]
  def change
    add_column :grocery_stores, :organic, :boolean, default: false
    rename_column :grocery_stores, :quality, :food_quantity
    remove_column :grocery_store_upload_statuses, :filename, :string
  end
end
