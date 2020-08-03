require 'google-maps'
require 'mapbox-sdk'

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
        parse_google_geocode if @geocoded
      elsif @place.only_needs_address?
        @geocoded = reverse_geocode
        parse_google_geocode if @geocoded
      elsif @place.zip.nil?
        @geocoded = reverse_geocode_only_zip
        parse_mapbox_geocode if @geocoded
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
    with_retries(max_tries: 3) {
      response = Google::Maps.geocode(location)
      response.first
    }
  rescue StandardError => err
    $stderr.print err
    $stderr.print err.backtrace
    nil
  end

  def reverse_geocode
    with_retries(max_tries: 3) {
      response = Google::Maps.geocode("#{@place.lat}, #{@place.long}")
      response.first
    }
  rescue StandardError => err
    $stderr.print err
    $stderr.print err.backtrace
    nil
  end

  private

  def parse_google_geocode
    @place.lat = @geocoded.latitude
    @place.long = @geocoded.longitude
    if !@place.zip.present?
      @place.zip = @geocoded.components["postal_code"].to_a[0]
    end
    if !@place.city.present?
      @place.city = @geocoded.components["locality"].to_a[0]
      @place.state = STATE_STATE_ABBR_MAP[@geocoded.components['administrative_area_level_1'].to_a[0]]
    end
    if !@place.address.present?
      @place.address = @geocoded.address.match(/[^,]+/).to_a[0]
    end
  end

  def parse_mapbox_geocode
    if !@place.zip.present?
      @place.zip = placenames.first["features"].find { |feature| feature["place_type"][0] == "postcode" }["text"].to_i
    end
  end
end