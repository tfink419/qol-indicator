class CreateGroceryStores < ActiveRecord::Migration[5.2]
  def up
    create_table :grocery_stores do |t|
      t.string :name, :limit => 100
      t.string :address, :limit => 100
      t.string :city, :limit => 100
      t.string :state, :limit => 50
      t.integer :zip
      t.float :lat, :null => false
      t.float :long, :null => false
      t.integer :quality, :default => 5

      t.timestamps
    end
    add_index(:grocery_stores, :lat)
    add_index(:grocery_stores, :long)
  end

  def down 
    drop_table :grocery_stores
  end
end
