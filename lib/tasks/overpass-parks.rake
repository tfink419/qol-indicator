require 'json'

task "overpass:parks" => :environment do
  parks = OverpassApiSearch.new("Colorado", [%w(leisure park)]).get_ways_and_nodes
  south = 9999
  west = 9999
  north = -9999
  east = -9999
  i = 0
  Park.import([:name, :openstreetmap_id, :lat, :long, :nodes], (parks.map do |place|
    puts "Park #{i += 1}"
    if place["type"] == "way"
      nodes = place["nodes"].map { |node| [node["lon"], node["lat"]]}
      lng, lat = NodeCentroid.new(nodes).get_centroid
      south = lat if lat < south
      north = lat if lat > north
      west = lng if lng < west
      east = lng if lng > east
      next [
        place["tags"]["name"],
        place["id"],
        lat,
        lng,
        nodes
      ]
    elsif place["type"] == "node"
      south = place["lat"] if place["lat"] < south
      north = place["lat"] if place["lat"] > north
      west = place["lon"] if place["lon"] < west
      east = place["lon"] if place["lon"] > east
      next [
        place["tags"]["name"],
        place["id"],
        place["lat"],
        place["lon"],
        [place["lon"], place["lat"]]
      ]
    end
  end), on_duplicate_key_ignore: true)

  unless south == 9999
    # Rebuild all points in the range of added grocery stores
    south_west = [(south-0.3).floor(1), (west-0.3).floor(1)]
    north_east = [(north+0.3).ceil(1), (east+0.3).ceil(1)]
    build_status = BuildQualityMapStatus.create(
      state:'initialized',
      percent:100,
      south_west:south_west,
      north_east:north_east,
      transit_type_low:1,
      transit_type_high:Park::NUM_TRANSIT_TYPES,
      point_type:'ParkActivitiesMapPoint'
    )
    HerokuWorkersService.new.start
    BuildQualityMapJob.perform_later(build_status)
  end
end
