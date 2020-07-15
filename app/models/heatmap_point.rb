require 'quality_map_image'

class HeatmapPoint < ApplicationRecord
  validates_with HeatmapPointValidator
  validates :transit_type, :presence => true
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
      if lat%128 == 0 && long%128 == 0
        self.precision = 0
      elsif lat%64 == 0 && long%64 == 0
        self.precision = 1
      elsif lat%32 == 0 && long%32 == 0
        self.precision = 2
      elsif lat%16 == 0 && long%16 == 0
        self.precision = 3
      elsif lat%8 == 0 && long%8 == 0
        self.precision = 4
      elsif lat%4 == 0 && long%4 == 0
        self.precision = 5
      elsif lat%2 == 0 && long%2 == 0
        self.precision = 6
      else
        self.precision = 7
      end
    end
  end

  def self.to_nearest_precision(num, precision)
    smallest = 2**(7-precision)
    big_num = (num*1000).round

    modulo = big_num%smallest
    if modulo >= smallest/2
      big_num += smallest-modulo
    else
      big_num -= modulo
    end
    (big_num/1000.0).round(3)
  end

  def self.zoom_to_precision_step(zoom)
    precision = 2
    step = 0.032
    if zoom > 11
      step = 0.001
      precision = 7
    elsif zoom > 7
      step = (0.001 * 2**(12-zoom)).round(3)
      precision = zoom-5
    end
    [precision, step]
  end

  def self.generate_image(south_west, north_east, zoom, transit_type)
    grocery_store_points = HeatmapPoint.where(transit_type: transit_type)\
    .where_in_coordinate_range(south_west, north_east, zoom)\
    .order(:lat, :long).pluck(:lat, :long, :quality)

    precision, step = zoom_to_precision_step(zoom)

    extra_long = (north_east[1]-south_west[1])*0.3
    extra_lat = (north_east[0]-south_west[0])*0.3
    extra_lat = step if extra_lat < step
    extra_long = step if extra_long < step
    south_west = [to_nearest_precision(south_west[0]-extra_lat,precision), to_nearest_precision(south_west[1]-extra_long,precision)]
    north_east = [to_nearest_precision(north_east[0]+extra_lat,precision), to_nearest_precision(north_east[1]+extra_long,precision)]

    south_west_int = south_west.map { |val| (val*1000).round.to_i }
    north_east_int = north_east.map { |val| (val*1000).round.to_i }

    step_int = (step*1000).round.to_i

    [south_west, north_east, QualityMapImage.get_image(south_west_int, north_east_int, step_int, grocery_store_points)]
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
