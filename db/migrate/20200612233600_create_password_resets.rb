class CreatePasswordResets < ActiveRecord::Migration[5.2]
  def change
    create_table :password_resets do |t|
      t.integer :user_id
      t.string :uuid, :limit => 36
      t.datetime :expires_at
    end
  add_index(:password_resets, :uuid)
  add_index(:password_resets, :expires_at)
  end
end
