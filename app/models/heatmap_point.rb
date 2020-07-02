class HeatmapPoint < ApplicationRecord
  validates_with HeatmapPointValidator
  validates :transit_type, :presence => true
  validates :lat, :presence => true
  validates :long, :presence => true
  validates :quality, :presence => true
  validates :precision, :presence => true

  scope :where_in_coordinate_range, lambda { |south_west, north_east, zoom|
    zoom = zoom.to_i
    if zoom > 10
      true_where_in_coordinate_range(south_west, north_east)
    elsif zoom > 4
      where(['precision < ?', zoom-2]).true_where_in_coordinate_range(south_west, north_east)
    else
      where(precision:2).true_where_in_coordinate_range(south_west, north_east)
    end
  }

  def as_array
    [lat, long, quality]
  end

  before_validation do
    if self.precision.nil?
      if lat.round == lat && long.round == long
        self.precision = 0
      elsif (lat*15.625).round == (lat*15.625) && (long*15.625).round == (long*15.625)
        self.precision = 1
      elsif (lat*31.25).round == (lat*31.25) && (long*31.25).round == (long*31.25)
        self.precision = 2
      elsif (lat*62.5).round == (lat*62.5) && (long*62.5).round == (long*62.5)
        self.precision = 3
      elsif (lat*125).round == (lat*125) && (long*125).round == (long*125)
        self.precision = 4
      elsif (lat*250).round == (lat*250) && (long*250).round == (long*250)
        self.precision = 5
      elsif (lat*500).round == (lat*500) && (long*500).round == (long*500)
        self.precision = 6
      else # (lat*1000).round == (lat*1000) && (long*1000).round == (long*1000)
        self.precision = 7
      end
    end
  end

  TRANSIT_TYPE_MAP = [
    ['walking', 8], # shouldn't be used
    ['walking', 8],
    ['walking', 16],
    ['walking', 24],
    ['cycling', 8],
    ['cycling', 16],
    ['cycling', 24],
    ['driving', 8],
    ['driving', 16],
    ['driving', 24],
    [nil, nil] # Might be used by "fly" value but shouldn't return anything
  ]

  private

  scope :true_where_in_coordinate_range, lambda { |south_west, north_east| 
    extra = ((north_east[0] - south_west[0])*0.2).round(2)
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', 
      (south_west[0]-extra).round(3), (north_east[0]+extra).round(3), (south_west[1]-extra).round(3), (north_east[1]+extra).round(3)])
  }
end
