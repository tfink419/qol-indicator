class AddFirstExtraColumnsToPreferences < ActiveRecord::Migration[5.2]
  def change
    rename_column :map_preferences, :transit_type, :grocery_store_quality_transit_type
    add_column :map_preferences, :census_tract_poverty_low, :integer, default: 5
    add_column :map_preferences, :census_tract_poverty_high, :integer, default: 40
    add_column :map_preferences, :census_tract_poverty_ratio, :integer, default: 50
    add_column :map_preferences, :grocery_store_quality_ratio, :integer, default: 50
  end
end
