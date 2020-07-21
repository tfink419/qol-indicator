require 'quality_map_image'

class GroceryStoreQualityMapPoint < ApplicationRecord
  validates :transit_type, :presence => true, uniqueness: { scope: [:lat, :long], message: 'not a unique transit type at lat and long.' }
  validates :lat, :presence => true
  validates :long, :presence => true
  validates :value, :presence => true
  validates :precision, :presence => true

  before_validation do
    if self.precision.nil?
      self.precision = MapPointService.precision_of(self.lat, self.long)
    end
  end
  
  TRANSIT_TYPE_MAP = [
    [nil, nil], # shouldn't be used
    ['walking', 8],
    ['walking', 16],
    ['walking', 24],
    ['cycling', 8],
    ['cycling', 16],
    ['cycling', 24],
    ['driving', 8],
    ['driving', 16],
    ['driving', 24]
  ]
  LOW = 0
  HIGH = 12.5
end
