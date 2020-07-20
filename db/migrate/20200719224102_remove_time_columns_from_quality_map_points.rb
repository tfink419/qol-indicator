class RemoveTimeColumnsFromQualityMapPoints < ActiveRecord::Migration[5.2]
  def change
    remove_column :grocery_store_quality_map_points, :updated_at, :datetime
    remove_column :grocery_store_quality_map_points, :created_at, :datetime
  end
end
