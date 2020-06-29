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

  validates :quality, :inclusion => 0..10

  has_many :isochrone_polygons, as: :isochronable

  before_validation do
    self.address = self.address.strip.titleize
    self.city = self.city.strip.titleize
    self.state = self.state.upcase
  end


  scope :clean_order, lambda { |attr, dir| 
    #ensure attr and dir are safe values to use by checking within an array of allowed values
    attr = (GroceryStore.attribute_names.include? attr) ? attr : 'created_at'
    dir.upcase!
    dir = (%w(ASC DESC).include? dir) ? dir : 'ASC'
    if ['name'].include? attr
      # case insensitive sort
      order(Arel.sql("lower(grocery_stores.#{attr}) #{dir}"))
    else
      order("#{attr} #{dir}")
    end
  }
  scope :search, lambda { |query| 
    search_query = "%#{query.gsub(/[^\w ]/,'')}%"
    where(['grocery_stores.name ILIKE ? or grocery_stores.address ILIKE ?', search_query, search_query])
  }

  scope :where_in_coordinate_range, lambda { |south_west, north_east| 
    extra = ((north_east[0] - south_west[0])*0.1).round(2)
    where(['lat > ? and lat < ? and long > ? and long < ?', south_west[0]-extra, north_east[0]+extra, south_west[1]-extra, north_east[1]+extra])
  }

  scope :all_near_point, lambda { |lat, long, transit_type|
    where(['lat > ? and lat < ? and long > ? and long < ?', lat-0.02*transit_type, lat+0.02*transit_type, long-0.02*transit_type, long+0.02*transit_type])
  }

  scope :all_near_point_wide, lambda { |lat, long|
    where(['lat > ? and lat < ? and long > ? and long < ?', lat-0.2, lat+0.2, long-0.2, long+0.3])
  }

  def valid_location?
    LocationValidator::valid_location?(city, state, zip)
  end

  def only_coordinates_invalid?
    self.valid?
    self.attribute_names.each do |attribute_name|
      next if attribute_name == 'lat' or attribute_name == 'long'
      return false unless self.errors[attribute_name].blank?
    end
    true
  end

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
      :quality => quality
    }
  end
end
