require 'net/http'

class OverpassApiSearch
  OVERPASS_URL = "https://overpass-api.de/api/interpreter"
  def initialize(state,  tags)
    @state = state
    @tags = tags
  end

  def get_nodes
    interpreter_data = "[out:json][timeout:60];"
    interpreter_data += "area[\"name\"=#{@state}][\"is_in:country_code\"=\"US\"]->.boundaryarea;"
    interpreter_data += "("
    @tags.each do |tag|
      interpreter_data += "node[\"#{tag[0]}\"=\"#{tag[1]}\"](area.boundaryarea);"
    end
    interpreter_data += ");out;"
    uri = URI(OVERPASS_URL)
    uri.query = "data=#{interpreter_data}"
    results = JSON.parse(Net::HTTP.get(uri))
    results['elements']
  end

  def get_ways_and_nodes
    interpreter_data = "[out:json][timeout:60];"
    interpreter_data += "area[\"name\"=#{@state}][\"is_in:country_code\"=\"US\"]->.boundaryarea;"
    interpreter_data += "("
    @tags.each do |tag|
      interpreter_data += "node[\"#{tag[0]}\"=\"#{tag[1]}\"](area.boundaryarea);"
      interpreter_data += "way[\"#{tag[0]}\"=\"#{tag[1]}\"](area.boundaryarea);>;"
    end
    interpreter_data += ");out;"
    uri = URI(OVERPASS_URL)
    uri.query = "data=#{interpreter_data}"
    results = JSON.parse(Net::HTTP.get(uri))
    return unless results['elements'].present?
    as_hash = results['elements'].reduce({}) do |hash, element|
      id = element["id"]
      to_hash = element.deep_dup
      to_hash.delete("id")
      hash[id] = to_hash
      hash
    end
    return_arr = []
    return_arr += results['elements'].reduce([]) do |new_arr, element|
      if element["type"] == "way" && element["tags"].to_h["name"].present?
        nodes = element["nodes"].map { |node| as_hash[node] }
        to_push = element.deep_dup
        to_push["nodes"] = nodes
        new_arr << to_push
      end
      new_arr
    end
    return_arr += results['elements'].filter do |element|
      element["type"] == "node" && element["tags"].to_h["name"].present?
    end
    return_arr
  end
end