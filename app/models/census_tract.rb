class CensusTract < ApplicationRecord
  validates :geoid, presence: true
  validates :poverty_percent, presence: true
  validates :land_area, presence: true
  validates :population, presence: true
  validates :population_density, presence: true
  has_one :census_tract_polygon, dependent: :destroy

  QUALITY_CALC_METHOD = 'First'
  QUALITY_CALC_VALUE = 0

  TAG_GROUPS = []

  def public_attributes
    {
      poverty_percent: poverty_percent,
      land_area: land_area,
      population: population,
      population_density: population_density
    }
  end
end
