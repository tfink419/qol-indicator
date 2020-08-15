class AddGinIndexToGroceryStoreTags < ActiveRecord::Migration[5.2]
  def change
    add_index :grocery_stores, :tags, using: :gin
  end
end
