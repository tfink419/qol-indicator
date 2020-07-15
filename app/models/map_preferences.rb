class MapPreferences < ApplicationRecord
  belongs_to :user
  validates :user_id, :presence => true
  validates :transit_type, :presence => true, :inclusion => 1..GroceryStore::NUM_TRANSIT_TYPES


  def public_attributes 
    {
      :transit_type => transit_type
    }
  end
end
