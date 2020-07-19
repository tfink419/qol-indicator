class CreateApiKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys do |t|
      t.string :key, null: false
      t.string :user_id, null: false
      t.timestamps
    end
    add_index :api_keys, :key, unique: true
    add_index :api_keys, :user_id
  end
end
