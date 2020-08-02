class GroceryStore < ApplicationRecord
  include ActiveModel::Validations
  validates_with LocationValidator

  validates :name, :presence => true,
    :length => { :maximum => 100 }
  validates :address, :presence => true,
    :length => { :maximum => 100 }
  validates :city,
    :length => { :maximum => 100 }
  validates :state,
    :length => { :maximum => 2 },
    :inclusion => { :in => LocationValidator::STATE_CODES, :message => 'is not a valid state.' }
  validates :lat, :presence => true, :inclusion => -180..180
  validates :long, :presence => true, :inclusion => -180..180
  validates :zip, :inclusion => { :in => [*0..99999, nil], :message => 'is not a valid zip code.' }

  validates :food_quantity, :inclusion => 0..10

  has_many :isochrone_polygons, as: :isochronable

  before_validation do
    self.address = self.address.strip.titleize if self.address
    self.city = self.city.strip.titleize if self.city
    self.state = self.state.upcase if self.state
  end

  NUM_TRANSIT_TYPES = 9

  after_destroy do
    # can not use dependent destroy because it destroys before
    IsochronePolygon.where(isochronable_id:self.id, isochronable_type:'GroceryStore').delete_all
  end

  scope :search, lambda { |query| 
    search_query = "%#{query.gsub(/[^\w ]/,'')}%"
    where(['grocery_stores.name ILIKE ? or grocery_stores.address ILIKE ?', search_query, search_query])
  }

  scope :where_in_coordinate_range, lambda { |south_west, north_east| 
    extra = (north_east[1] - south_west[1])*0.1
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', (south_west[0]-extra).round(3), (north_east[0]+extra).round(3), (south_west[1]-extra).round(3), (north_east[1]+extra).round(3)])
  }

  scope :all_near_point, lambda { |lat, long, transit_type|
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', (lat-0.02*transit_type).round(3), (lat+0.02*transit_type).round(3), (long-0.02*transit_type).round(3), (long+0.02*transit_type).round(3)])
  }

  scope :all_near_point_wide, lambda { |lat, long, transit_type|
    extra_length = 0.03+transit_type*0.03
    where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', (lat-extra_length).round(3), (lat+extra_length).round(3), (long-extra_length).round(3), (long+extra_length+0.1).round(3)])
  }

  def valid_location?
    LocationValidator::valid_location?(city, state, zip)
  end

  def only_coordinates_invalid?
    self.valid?
    self.attribute_names.each do |attribute_name|
      next if %w(lat long).include? attribute_name
      return false unless self.errors[attribute_name].blank?
    end
    true
  end

  def only_needs_address?
    self.valid?
    self.attribute_names.each do |attribute_name|
      next if %w(address city state zip).include? attribute_name
      return false unless self.errors[attribute_name].blank?
    end
    true
  end

  QUALITY_CALC_METHOD = 'LogExpSum'
  QUALITY_CALC_VALUE = 1.7

  def public_attributes
    {
      :id => id,
      :name => name,
      :address => address,
      :city => city,
      :state => state,
      :zip => zip,
      :lat => lat,
      :long => long,
      :food_quantity => food_quantity
    }
  end
end
