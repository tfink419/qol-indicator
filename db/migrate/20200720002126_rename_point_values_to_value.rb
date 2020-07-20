class RenamePointValuesToValue < ActiveRecord::Migration[5.2]
  def change
    rename_column :grocery_store_quality_map_points, :quality, :value
    rename_column :census_tract_poverty_map_points, :poverty_percent, :value
  end
end
