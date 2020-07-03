require 'geokit'

class IsochronePolygon < ApplicationRecord
  validates_with IsochronePolygonValidator
  validates :distance, :presence => true
  validates :travel_type, :presence => true
  validates :polygon, exclusion: { in: [nil], message: 'can\'t be nil' }

  def as_mapbox_poly
    [{
      "features":
        [{
          "properties":{"fillOpacity":0.33,"color":"#bf4040","fill":"#bf4040","fillColor":"#bf4040","contour":30,"opacity":0.33,"fill-opacity":0.33},
          "type":"Feature",
          "geometry":{
            "coordinates":[string_path_to_float(self.polygon)],
            "type":"Polygon"
        }}],
      "type":"FeatureCollection"
    }, {}]
  end

  def get_geokit_polygon
    unless geokit_polygon
      geokit_polygon = Geokit::Polygon.new(polygon.map { |coord| Geokit::LatLng.new(coord[1], coord[0]) })
    end
    geokit_polygon
  end

  def get_polygon_floats
    string_path_to_float(self.polygon)
  end

  def self.to_mapbox_poly(polygon)
    [{
      "features":
        [{
          "properties":{"fillOpacity":0.33,"color":"#bf4040","fill":"#bf4040","fillColor":"#bf4040","contour":30,"opacity":0.33,"fill-opacity":0.33},
          "type":"Feature",
          "geometry":{
            "coordinates":[polygon],
            "type":"Polygon"
        }}],
      "type":"FeatureCollection"
    }, {}]
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
