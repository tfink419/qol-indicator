class CensusTractPovertyMapPoint < ApplicationRecord
  validates :lat, :presence => true
  validates :long, :presence => true
  validates :value, :presence => true
  validates :precision, :presence => true

  before_validation do
    if self.precision.nil?
      self.precision = MapPointService.precision_of(self.lat, self.long)
    end
  end
end
