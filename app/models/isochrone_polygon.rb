class IsochronePolygon < ApplicationRecord
  validates_with IsochronePolygonValidator
  validates :distance, :presence => true
  validates :travel_type, :presence => true
  validates :geometry, exclusion: { in: [nil], message: 'can\'t be nil' }
  validates :south_bound, :presence => true
  validates :north_bound, :presence => true
  validates :west_bound, :presence => true
  validates :east_bound, :presence => true

  before_validation do
    PolygonService.new(self).set_bounds
  end

  def self.extract_geo_from_mapbox(resp)
    if resp[0]['features']
      resp[0]['features'][0]['geometry']['coordinates']
    else
      resp[0][:features][0][:geometry][:coordinates]
    end
  end
end
