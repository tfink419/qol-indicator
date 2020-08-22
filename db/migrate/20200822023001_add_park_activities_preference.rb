class AddParkActivitiesPreference < ActiveRecord::Migration[5.2]
  def change
    add_column :map_preferences, :park_ratio, :integer, default: 50
    add_column :map_preferences, :park_transit_type, :integer, default: 2
  end
end
