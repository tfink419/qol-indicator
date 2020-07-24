require 'net/http'

class OverpassApiPlaceSearch
  OVERPASS_URL = "https://overpass-api.de/api/interpreter"
  def initialize(location, tags)
    @location = location
    @tags = tags
  end

  def each
    interpreter_data = "[out:json][timeout:60];"
    interpreter_data += "area[\"name\"=#{@location}]->.boundaryarea;"
    interpreter_data += "("
    @tags.each do |tag|
      interpreter_data += "node[#{tag}](area.boundaryarea);"
    end
    interpreter_data += ");out;"
    uri = URI(OVERPASS_URL)
    uri.query = "data=#{interpreter_data}"
    results = JSON.parse(Net::HTTP.get(uri))
    return unless results['elements'].present?
    results['elements'].each do |element|
      yield element
    end
  end
end