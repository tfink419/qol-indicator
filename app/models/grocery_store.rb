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
  validates :google_place_id, uniqueness: true, allow_nil: true
  validates :zip, :inclusion => { :in => [*0..99999, nil], :message => 'is not a valid zip code.' }

  validates :food_quantity, :inclusion => 0..10

  has_many :isochrone_polygons, as: :isochronable

  before_validation do
    self.address = self.address.strip.titleize if self.address
    self.city = self.city.strip.titleize if self.city
    self.state = self.state.upcase if self.state
  end

  NUM_TRANSIT_TYPES = 9


  # List of tags so far
  # ["restaurant", "supermarket", "movie_rental", "hardware_store", "farm", 
  # "general_contractor", "car_repair", "meal_delivery", "finance", "bank",
  # "home_goods_store", "greengrocer", "deli", "tourist_attraction", "travel_agency",
  # "atm", "bar", "laundry", "butcher", "convenience_store", "clothing_store",
  # "car_wash", "night_club", "car_rental", "bakery", "lodging", "campground",
  # "drugstore", "locksmith", "health", "spa", "liquor_store", "pastry", "seafood",
  # "dollar_store", "furniture_store", "storage", "rv_park", "department_store",
  # "real_estate_agency", "pet_store", "veterinary_care", "hair_care", "health_food",
  # "organic", "movie_theater", "wholesale", "jewelry_store", "shoe_store",
  # "shopping_mall", "gym", "gas_station", "florist", "electronics_store", "cafe",
  # "art_gallery", "book_store", "beauty_salon", "cheese", "grocery_or_supermarket",
  # "meal_takeaway", "park", "pharmacy"]

  # true == required
  # required must be on top

  TAG_GROUPS = [
    [true, %w(organic)], # Organic food
    [false, %w(supermarket grocery_or_supermarket)], # Supermarkets, Grocery Stores
    [false, %w(wholesale)], # Wholesale Stores (AKA Sam's Club / Costco)
    [false, %w(gas_station convenience_store dollar_store)], # Convenience Stores
    [false, %w(deli butcher seafood)], # Non-Vegetarian Specialties
    [false, %w(cheese)], # Cheese
    [false, %w(bakery pastry)], # Vegan Specialties
    false # Other categories (not in categories above)
  ]

  TAG_GROUPS_CALC_SIZE = 2**(TAG_GROUPS.length)-1

  TAG_OTHER_NOT = TAG_GROUPS.flatten.filter {|obj| obj.is_a?(String) }

  after_destroy do
    IsochronePolygon.where(isochronable_id:self.id, isochronable_type:'GroceryStore').delete_all
  end

  scope :search, lambda { |query| 
    search_query = "%#{query.gsub(/[^\w ]/,'')}%"
    where(['grocery_stores.name ILIKE ? or grocery_stores.address ILIKE ?', search_query, search_query])
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
  QUALITY_CALC_VALUE = 1.8

  def public_attributes
    {
      id: id,
      name: name,
      address: address,
      city: city,
      state: state,
      zip: zip,
      lat: lat,
      long: long,
      food_quantity: food_quantity,
      tags: tags
    }
  end
end
