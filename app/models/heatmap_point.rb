require 'gradient'
# require 'oily_png'

GRADIENT_MAP = Gradient::Map.new(
  Gradient::Point.new(0, Color::RGB.new(255, 0, 0), 0.5),
  Gradient::Point.new(0.2, Color::RGB.new(255, 165, 0), 0.5),
  Gradient::Point.new(0.5, Color::RGB.new(255, 255, 0), 0.5),
  Gradient::Point.new(0.8, Color::RGB.new(0, 255, 0), 0.5),
  Gradient::Point.new(1, Color::RGB.new(0, 255, 255), 0.5)
)

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
      where(['precision <= ?', zoom-4]).true_where_in_coordinate_range(south_west, north_east)
    elsif zoom > 3
      where(['precision <= ?', zoom-3]).true_where_in_coordinate_range(south_west, north_east)
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
      step = (0.001 * 2**(11-zoom)).round(3)
      precision = zoom-4
    elsif zoom > 3
      step = (0.001 * 2**(10-zoom)).round(3)
      precision = zoom-3
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
    south_west = [to_nearest_precision(south_west[0]-extra_lat,precision), to_nearest_precision(south_west[1]-extra_long,precision)]
    north_east = [to_nearest_precision(north_east[0]+extra_lat,precision), to_nearest_precision(north_east[1]+extra_long,precision)]

    south_west_int = south_west.map { |val| (val*1000).round.to_i }
    north_east_int = north_east.map { |val| (val*1000).round.to_i }

    width = ((north_east[1]-south_west[1])/step).round+1
    height = ((north_east[0]-south_west[0])/step).round+1

    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color('red @ 0.6'))
    
    step_int = (step*1000).round.to_i
    heatmap_points = []
    lat = south_west_int[0]
    y = height-1
    gstore_ind = 0
    current_gstore_point = grocery_store_points[gstore_ind]
    # ierate through both "arrays", only works on sorted in same exact way
    while lat <= north_east_int[0]
      long = south_west_int[1]
      x = 0
      while long <= north_east_int[1]
        quality = 0
        if current_gstore_point && current_gstore_point[0] == lat && current_gstore_point[1] == long
          quality = current_gstore_point[2]
          gstore_ind += 1
          current_gstore_point = grocery_store_points[gstore_ind]
        end
        quality = 12.5 if quality > 12.5
        quality = 0 if quality < 0

        color = GRADIENT_MAP.at(quality/12.5).color

        png[x,y] = ChunkyPNG::Color.rgba(color.red.to_i, color.green.to_i, color.blue.to_i, 154)
        x += 1
        long += step_int
      end
      y -= 1
      lat += step_int
    end

    south_west = south_west.map { |val| val+step/2 }
    north_east = north_east.map { |val| val+step/2 }
    if zoom < 7 # WTF is up with this
      magic_bug_offset = 0.06*extra_lat*1.2**extra_lat
      south_west[0] -= magic_bug_offset
      north_east[0] -= magic_bug_offset
    end
    [south_west, north_east, png.to_datastream(:fast_rgba)]
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
    extra_long = (north_east[1]-south_west[1])*0.2
    extra_lat = (north_east[0]-south_west[0])*0.2
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', 
      (south_west[0]-extra_lat)*1000, (north_east[0]+extra_lat)*1000, (south_west[1]-extra_long)*1000, (north_east[1]+extra_long)*1000])
  }
end
