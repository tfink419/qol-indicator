class Park < ApplicationRecord
  validates :name, :presence => true,
    :length => { :maximum => 100 }
  validates :lat, :presence => true, :inclusion => -180..180
  validates :long, :presence => true, :inclusion => -180..180
  validates :openstreetmap_id, uniqueness: true, allow_nil: true

  validates :num_activities, :inclusion => 0..10

  has_many :isochrone_polygons, as: :isochronable

  NUM_TRANSIT_TYPES = 6

  after_destroy do
    IsochronePolygon.where(isochronable_id:self.id, isochronable_type:'Park').delete_all
  end

  scope :search, lambda { |query| 
    search_query = "%#{query.gsub(/[^\w ]/,'')}%"
    where(['parks.name ILIKE ? ', search_query])
  }

  QUALITY_CALC_METHOD = 'LogExpSum'
  QUALITY_CALC_VALUE = 1.4

  def public_attributes
    {
      id: id,
      name: name,
      lat: lat,
      long: long,
      num_activities: num_activities
    }
  end

end
