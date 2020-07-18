require 'quality_map_image'

class HeatmapPoint < ApplicationRecord
  validates :transit_type, :presence => true, uniqueness: { scope: [:lat, :long], message: 'not a unique transit type at lat and long.' }
  validates :lat, :presence => true
  validates :long, :presence => true
  validates :quality, :presence => true
  validates :precision, :presence => true

  scope :where_in_coordinate_range, lambda { |south_west, north_east, zoom|
    zoom = zoom.to_i
    if zoom > 11
      true_where_in_coordinate_range(south_west, north_east)
    elsif zoom > 7
      where(['precision <= ?', zoom-5]).true_where_in_coordinate_range(south_west, north_east)
    else
      where(['precision <= ?', 2]).true_where_in_coordinate_range(south_west, north_east)
    end
  }

  before_validation do
    if self.precision.nil?
      self.precision = self.class.precision_of(self.lat, self.long)
    end
  end

  def self.precision_of(lat, long)
    precision = nil
    if lat && long
      if lat%128 == 0 && long%128 == 0
        precision = 0
      elsif lat%64 == 0 && long%64 == 0
        precision = 1
      elsif lat%32 == 0 && long%32 == 0
        precision = 2
      elsif lat%16 == 0 && long%16 == 0
        precision = 3
      elsif lat%8 == 0 && long%8 == 0
        precision = 4
      elsif lat%4 == 0 && long%4 == 0
        precision = 5
      elsif lat%2 == 0 && long%2 == 0
        precision = 6
      else
        precision = 7
      end
    end
    precision
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

  private

  scope :true_where_in_coordinate_range, lambda { |south_west, north_east|
    extra_long = (north_east[1]-south_west[1])*0.2
    extra_lat = (north_east[0]-south_west[0])*0.2
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', 
      (south_west[0]-extra_lat)*1000, (north_east[0]+extra_lat)*1000, (south_west[1]-extra_long)*1000, (north_east[1]+extra_long)*1000])
  }
end
