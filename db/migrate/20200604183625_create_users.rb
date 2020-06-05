class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name, :limit => 50
      t.string :last_name, :limit => 50
      t.string :username, :limit => 50
      t.string :email, :null => false
      t.string :password_digest
      t.boolean :is_admin, :default => false

      t.timestamps
    end
    add_index(:users, :username)
  end
end
