require "retries"
require 'mapbox'
require 'mapbox-sdk'

class FetchIsochrone
  def initialize(isochronable)
    @isochronable = isochronable
  end

  def fetch(transit_type_low, transit_type_high)
    isochrones = []
    tries = 0
    (transit_type_low..transit_type_high).each do |transit_type|
      travel_type, distance = GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP[transit_type]
      no_isochrones = @isochronable.isochrone_polygons.where(travel_type:travel_type, distance:distance).none?
      if no_isochrones
        isochrone = nil
        with_retries(max_tries: 10, base_sleep_seconds: 15, max_sleep_seconds: 60) {
          isochrone = Mapbox::Isochrone.isochrone(travel_type, "#{@isochronable.long},#{@isochronable.lat}", {contours_minutes: [distance], generalize: 25, polygons:true})
        }
        isochrones << {travel_type:travel_type, distance:distance, geometry:'['+IsochronePolygon.extract_geo_from_mapbox(isochrone)+']'}
      end
    end
    @isochronable.isochrone_polygons.create(isochrones)
  end
end