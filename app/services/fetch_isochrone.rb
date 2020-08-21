require "retries"
require 'mapbox'
require 'mapbox-sdk'
require 'clipper'

class FetchIsochrone
  def initialize(isochronable, transit_type_map, multi = false)
    @isochronable = isochronable
    @transit_type_map = transit_type_map
    @multi = multi
  end

  def fetch(transit_type_low, transit_type_high)
    isochrones = []
    tries = 0
    (transit_type_low..transit_type_high).each do |transit_type|
      travel_type, distance = @transit_type_map[transit_type]
      if @isochronable.isochrone_polygons.where(travel_type:travel_type, distance:distance).none?
        geo = nil
        case @isochronable.class.name
        when "GroceryStore"
          geo = get_geo_from_mapbox(travel_type, distance)
        when "Park"
          geo = get_geos_from_mapbox_and_union(travel_type, distance)
        end
        unless geo.nil?
          isochrones << {travel_type:travel_type, distance:distance, geometry:geo}
        end
      end
    end
    @isochronable.isochrone_polygons.create(isochrones)
  end

  private

  def get_geo_from_mapbox(travel_type, distance)
    isochrone = nil
    with_retries(max_tries: 20, base_sleep_seconds: 15, max_sleep_seconds: 60) {
      isochrone = Mapbox::Isochrone.isochrone(travel_type, "#{@isochronable.long},#{@isochronable.lat}", {contours_minutes: [distance], generalize: 25, polygons:true})
    }
    geo = IsochronePolygon.extract_geo_from_mapbox(isochrone)
    return geo.map{ |poly| [poly] } unless geo.empty? || geo.first.empty?
  end 

  def get_geos_from_mapbox_and_union(travel_type, distance)
    isochrones = nil
    puts "Fetching Isochrones"
    @isochronable.nodes.each do |node|
      with_retries(max_tries: 20, base_sleep_seconds: 15, max_sleep_seconds: 60) {
        isochrones << Mapbox::Isochrone.isochrone(travel_type, "#{@node[0]},#{@node[1]}", {contours_minutes: [distance], generalize: 25, polygons:true})
      }
    end
    c = Clipper::Clipper.new
    first_done = false
    puts "Joining Isochrones"
    isochrones.each do |isochrone|
      geo = IsochronePolygon.extract_geo_from_mapbox(isochrone)
      unless geo.empty? || geo.first.empty?
        if first_done
          c.add_clip_polygon(geo)
        else
          c.add_subject_polygons(geo)
          first_done = true
        end
      end
    end
    if first_done
      c.union(:non_zero, :non_zero).map{ |poly| [poly] }
    end
  end 
end