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

  has_many :isochrone_polygons, as: :isochronable, dependent: :destroy

  before_validation do
    self.address = self.address.strip.titleize
    self.city = self.city.strip.titleize
    self.state = self.state.upcase
  end

  after_update do
    if self.quality_previously_changed?
      (1..9).each do |transit_type|
        travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
        isochrone = IsochronePolygon.where(isochronable_id:self.id, isochronable_type:'GroceryStore', travel_type:travel_type, distance:distance).first
        south_west_int = [(isochrone.south_bound.floor(1)*1000).round.to_i, (isochrone.west_bound.floor(1)*1000).round.to_i]
        north_east_int = [(isochrone.north_bound.ceil(1)*1000).round.to_i, (isochrone.east_bound.ceil(1)*1000).round.to_i]
        build_status = BuildHeatmapStatus.create(state:'initialized', percent:100,
        rebuild:true, south_west:south_west_int, north_east:north_east_int,
        transit_type_low:transit_type, transit_type_high:transit_type)
        puts "Enqueued: #{build_status.as_json}"
        BuildHeatmapJob.set(wait: ((transit_type-1)*15).seconds).perform_later(build_status)
      end
    elsif self.lat_previously_changed? || self.long_previously_changed?
      puts "coord changed"
    end
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
      next if attribute_name == 'lat' or attribute_name == 'long'
      return false unless self.errors[attribute_name].blank?
    end
    true
  end

  def self.furthest_south_west
    [(GroceryStore.minimum(:lat)-0.3).floor(1), (GroceryStore.minimum(:long)-0.3).floor(1)]
  end

  def self.furthest_north_east
    [(GroceryStore.maximum(:lat)+0.3).ceil(1), (GroceryStore.maximum(:long)+0.3).ceil(1)]
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
