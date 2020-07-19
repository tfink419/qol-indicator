class CensusTractPolygon < ApplicationRecord
  validates :polygon, exclusion: { in: [nil], message: 'can\'t be nil' }
  validates :south_bound, presence: true
  validates :north_bound, presence: true
  validates :west_bound, presence: true
  validates :east_bound, presence: true

  belongs_to :census_tract

  before_validation do
    PolygonService.new(self).set_bounds
  end
end
