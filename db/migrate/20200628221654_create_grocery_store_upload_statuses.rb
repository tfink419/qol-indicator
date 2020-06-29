class CreateGroceryStoreUploadStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :grocery_store_upload_statuses do |t|
      t.float :percent, nil: false
      t.string :state, nil: false
      t.string :message
      t.string :filename, nil: false
      t.text :details
      t.text :error
      t.timestamps
    end
  end
end
