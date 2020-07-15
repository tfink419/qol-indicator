require 'google-maps'

class Geocode
  STATE_ABBR_STATE_MAP = {
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

  STATE_STATE_ABBR_MAP = {
    nil => "",
    "" => "",
    "Alaska" => "AK",
    "Alabama" => "AL",
    "Arkansas" => "AR",
    "American Samoa" => "AS",
    "Arizona" => "AZ",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "District of Columbia" => "DC",
    "Delaware" => "DE",
    "Florida" => "FL",
    "Georgia" => "GA",
    "Guam" => "GU",
    "Hawaii" => "HI",
    "Iowa" => "IA",
    "Idaho" => "ID",
    "Illinois" => "IL",
    "Indiana" => "IN",
    "Kansas" => "KS",
    "Kentucky" => "KY",
    "Louisiana" => "LA",
    "Massachusetts" => "MA",
    "Maryland" => "MD",
    "Maine" => "ME",
    "Michigan" => "MI",
    "Minnesota" => "MN",
    "Missouri" => "MO",
    "Mississippi" => "MS",
    "Montana" => "MT",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Nebraska" => "NE",
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "Nevada" => "NV",
    "New York" => "NY",
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Puerto Rico" => "PR",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Virginia" => "VA",
    "Virgin Islands" => "VI",
    "Vermont" => "VT",
    "Washington" => "WA",
    "Wisconsin" => "WI",
    "West Virginia" => "WV",
    "Wyoming" => "WY" 
  }
  def initialize(place)
    @place = place
  end
  
  def attempt_geocode_if_needed
    unless @place.valid?
      if @place.only_coordinates_invalid?
        @geocoded = geocode
        parse_geocode if @geocoded
        puts @place.as_json
      end
    end
  end

  def geocode
    if @place.zip.nil?
      location = "#{@place.address}, #{@place.city}, #{STATE_ABBR_STATE_MAP[@place.state]}"
    elsif @place.city.nil? or @place.city.empty?
      location = "#{@place.address}, #{@place.zip}"
    else
      location = "#{@place.address}, #{@place.city}, #{STATE_ABBR_STATE_MAP[@place.state]}, #{@place.zip}"
    end
    with_reties(max_tries: 3) {
      response = Google::Maps.geocode(location)
    }
    response.first
  rescue StandardError => err
    $stderr.print err
    $stderr.print err.backtrace
    nil
  end

  private

  def parse_geocode
    @place.lat = @geocoded.latitude
    @place.long = @geocoded.longitude
    if @place.zip.nil?
      @place.zip = @geocoded.components["postal_code"].first
    elsif @place.city.nil? or @place.city.empty?
      @place.city = @geocoded.components["locality"].first
      @place.state = STATE_STATE_ABBR_MAP[@geocoded.components['administrative_area_level_1'].first]
    end
  end
end