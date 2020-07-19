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
    PolygonService.new(self).set_bounds
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

  def string_path_to_float(path)
    path.map { |coord| coord.map(&:to_f)}
  end
end
