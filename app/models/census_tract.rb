class CensusTract < ApplicationRecord
  validates :geoid, presence: true
  validates :povery_percent, presence: true
  validates :land_area, presence: true
  validates :population, presence: true
  validates :population_density, presence: true
  has_one :census_tract_polygon, dependent: :destroy
end
