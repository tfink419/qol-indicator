class CreateMapPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :map_preferences do |t|
      t.integer :user_id, :null => false
      t.integer :transit_type, :default => 2
    end
  add_index(:map_preferences, :user_id)
end
end
