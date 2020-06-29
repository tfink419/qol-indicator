require 'mapbox-sdk'

Mapbox.access_token = ENV["MAPBOX_TOKEN"]

class Geocode
  class << Geocode
    def attempt_geocode_if_needed(place)
      unless place.valid?
        if place.only_coordinates_invalid?
          geocoded = geocode(place.address, place.city, place.state, place.zip)
          parse_geocode(place, geocoded)
        end
      end
    end

    def geocode(address, city, state, zip)
      if zip.nil?
        location = "#{address}, #{city}, #{state}"
      elsif city.nil? or city.empty?
        location = "#{address}, #{zip}"
      else
        location = "#{address}, #{city}, #{state}, #{zip}"
      end
      response = Mapbox::Geocoder.geocode_forward(location, { country:'US', types:['address']})
      return response[0]["features"][0]
    end

    private

    def parse_context(geocoded)
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

    def parse_geocode(place, geocoded)
      parse_context(geocoded)
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
end