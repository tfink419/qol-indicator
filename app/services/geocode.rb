require 'mapbox'
require 'mapbox-sdk'
Mapbox.access_token = ENV["MAPBOX_TOKEN"]


class Geocode
  STATE_MAP = {
    nil => "",
    "" => "",
    "AK" => "Alaska",
    "AL" => "Alabama",
    "AR" => "Arkansas",
    "AS" => "American Samoa",
    "AZ" => "Arizona",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DC" => "District of Columbia",
    "DE" => "Delaware",
    "FL" => "Florida",
    "GA" => "Georgia",
    "GU" => "Guam",
    "HI" => "Hawaii",
    "IA" => "Iowa",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "MA" => "Massachusetts",
    "MD" => "Maryland",
    "ME" => "Maine",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MO" => "Missouri",
    "MS" => "Mississippi",
    "MT" => "Montana",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "NE" => "Nebraska",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NV" => "Nevada",
    "NY" => "New York",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "PR" => "Puerto Rico",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VA" => "Virginia",
    "VI" => "Virgin Islands",
    "VT" => "Vermont",
    "WA" => "Washington",
    "WI" => "Wisconsin",
    "WV" => "West Virginia",
    "WY" => "Wyoming" 
  }
  
  def self.attempt_geocode_if_needed(place)
    unless place.valid?
      if place.only_coordinates_invalid?
        geocoded = geocode(place.address, place.city, place.state, place.zip)
        parse_geocode(place, geocoded) if geocoded
      end
    end
  end

  def self.geocode(address, city, state, zip)
    if zip.nil?
      location = "#{address}, #{city}, #{STATE_MAP[state]}"
    elsif city.nil? or city.empty?
      location = "#{address}, #{zip}"
    else
      location = "#{address}, #{city}, #{STATE_MAP[state]}, #{zip}"
    end
    response = Mapbox::Geocoder.geocode_forward(location, { country:'US', types:['address']})
    response[0]["features"][0]
  rescue StandardError => err
    $stderr.print err
    $stderr.print err.backtrace
    nil
  end

  private

  def self.parse_context(geocoded)
    geocoded["context"].each do |context|
      if context["id"].include? "postcode"
        geocoded["postalCode"] = context["text"]
      elsif context["id"].include? "place"
        geocoded["city"] = context["text"]
      elsif context["id"].include? "region"
        geocoded["state"] = context["short_code"][3..-1]
      end
    end
  end

  def self.parse_geocode(place, geocoded)
    parse_context(geocoded)
    return if geocoded['relevance'] < 0.75 # Bad geocode
    place.lat = geocoded['center'][1]
    place.long = geocoded['center'][0]
    if place.zip.nil?
      place.zip = geocoded['postalCode']
    elsif place.city.nil? or place.city.empty?
      place.city = geocoded['city']
      place.state = geocoded['state']
    end
  end
end