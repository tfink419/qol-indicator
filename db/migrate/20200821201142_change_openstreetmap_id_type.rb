class ChangeOpenstreetmapIdType < ActiveRecord::Migration[5.2]
  def up 
    change_column :parks, :openstreetmap_id, :text
  end

  def down
    change_column :parks, :openstreetmap_id, :interger
  end
end
