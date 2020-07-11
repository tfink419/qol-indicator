class MapPreferences < ApplicationRecord
  belongs_to :user
  validates :user_id, :presence => true
  validates :transit_type, :presence => true, :inclusion => 1..9


  def public_attributes 
    {
      :transit_type => transit_type
    }
  end
end
