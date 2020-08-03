class MapPreferences < ApplicationRecord
  belongs_to :user
  validates :user_id, :presence => true
  validates :grocery_store_transit_type, :presence => true, :inclusion => 1..GroceryStore::NUM_TRANSIT_TYPES
  validates :census_tract_poverty_low, :presence => true, :inclusion => 0..100
  validates :census_tract_poverty_high, :presence => true, :inclusion => 0..100
  validates :grocery_store_ratio, :presence => true, :inclusion => 0..100
  validates :census_tract_poverty_ratio, :presence => true, :inclusion => 0..100
  validates :grocery_store_tags, :presence => true, :inclusion => 0..GroceryStore::TAG_GROUPS_CALC_SIZE


  def public_attributes 
    {
      grocery_store_transit_type: grocery_store_transit_type,
      census_tract_poverty_low: census_tract_poverty_low,
      census_tract_poverty_high: census_tract_poverty_high,
      grocery_store_ratio: grocery_store_ratio,
      census_tract_poverty_ratio: census_tract_poverty_ratio,
      grocery_store_tags: grocery_store_tags
    }
  end
end
