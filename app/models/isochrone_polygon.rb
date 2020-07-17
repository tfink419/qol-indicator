require 'geokit'

class IsochronePolygon < ApplicationRecord
  validates_with IsochronePolygonValidator
  validates :distance, :presence => true
  validates :travel_type, :presence => true
  validates :polygon, exclusion: { in: [nil], message: 'can\'t be nil' }
  validates :south_bound, :presence => true
  validates :north_bound, :presence => true
  validates :west_bound, :presence => true
  validates :east_bound, :presence => true

  before_validation do
    if self.polygon
      self.west_bound = self.polygon.min { |a, b| a[0].to_f <=> b[0].to_f }[0].to_f
      self.east_bound = self.polygon.max { |a, b| a[0].to_f <=> b[0].to_f }[0].to_f
      self.south_bound = self.polygon.min { |a, b| a[1].to_f <=> b[1].to_f }[1].to_f
      self.north_bound = self.polygon.max { |a, b| a[1].to_f <=> b[1].to_f }[1].to_f
    end
  end

  scope :all_near_point_fat, lambda { |lat, long, lat_height, long_width|
    east = (long+long_width-1)/1000.0
    north = (lat+lat_height-1)/1000.0
    south = lat/1000.0
    west = long/1000.0
    if lat_height == 0 && long_width == 0
      where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', south, south, west, west])
    elsif lat_height == 0
      where(['south_bound <= ? AND ? <= north_bound AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, west, west, east, east, west, east])
    elsif long_width == 0
      where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND west_bound <= ? AND ? <= east_bound', 
      south, south, north, north, south, north, west, west])
    else
      where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, north, north, south, north, west, west, east, east, west, east])
    end
  }

  def get_geokit_polygon
    unless geokit_polygon
      geokit_polygon = Geokit::Polygon.new(polygon.map { |coord| Geokit::LatLng.new(coord[1], coord[0]) })
    end
    geokit_polygon
  end

  def get_polygon_floats
    string_path_to_float(self.polygon)
  end

  def self.extract_poly_from_mapbox(resp)
    if resp[0]['features']
      resp[0]['features'][0]['geometry']['coordinates'][0]
    else
      resp[0][:features][0][:geometry][:coordinates][0]
    end
  end

  private

  attribute :geokit_polygon, :default => nil

  def string_path_to_float(path)
    path.map { |coord| coord.map(&:to_f)}
  end
end
