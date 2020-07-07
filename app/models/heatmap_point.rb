require 'gradient'

GRADIENT_MAP = Gradient::Map.new(
  Gradient::Point.new(0, Color::RGB.new(255, 0, 0), 0.5),
  Gradient::Point.new(0.2, Color::RGB.new(255, 165, 0), 0.5),
  Gradient::Point.new(0.5, Color::RGB.new(255, 255, 0), 0.5),
  Gradient::Point.new(0.8, Color::RGB.new(0, 255, 0), 0.5),
  Gradient::Point.new(1, Color::RGB.new(0, 0, 255), 0.5)
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
    elsif zoom > 4
      where(['precision < ?', zoom-3]).true_where_in_coordinate_range(south_west, north_east)
    else
      where(precision:2).true_where_in_coordinate_range(south_west, north_east)
    end
  }

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
    precision = 0
    step = 0.064
    if zoom > 11
      step = 0.001
      precision = 7
    elsif zoom > 4
      step = (0.001 * 2**(11-zoom)).round(3)
      precision = zoom-4
    else
      step = 0.032
      precision = 2
    end
    [precision, step]
  end

  def self.generate_image(south_west, north_east, zoom, transit_type)
    grocery_store_points = HeatmapPoint.where(transit_type: transit_type)\
    .where_in_coordinate_range(south_west, north_east, zoom).limit(300000)\
    .order(:lat, :long).pluck(:lat, :long, :quality)

    puts "Num Points: #{grocery_store_points.length}"

    precision, step = zoom_to_precision_step(zoom)

    extra = (north_east[1]-south_west[1])*0.3
    south_west = [to_nearest_precision(south_west[0]-extra,precision), to_nearest_precision(south_west[1]-extra,precision)]
    north_east = [to_nearest_precision(north_east[0]+extra,precision), to_nearest_precision(north_east[1]+extra,precision)]

    width = ((north_east[1]-south_west[1])/step).round+1
    height = ((north_east[0]-south_west[0])/step).round+1

    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color('red @ 0.5'))
    
    heatmap_points = []
    lat = south_west[0]
    y = height-1
    gstore_ind = 0
    current_gstore_point = grocery_store_points[gstore_ind]
    # ierate through both "arrays", only works on sorted in same exact way
    while lat <= north_east[0]
      long = south_west[1]
      x = 0
      while long <= north_east[1]
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
        long = (long+step).round(3)
      end
      y -= 1
      lat = (lat+step).round(3)
    end
    png.to_datastream()
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
    extra = (north_east[1] - south_west[1])*0.2
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', 
      (south_west[0]-extra).round(3), (north_east[0]+extra).round(3), (south_west[1]-extra).round(3), (north_east[1]+extra).round(3)])
  }
end
