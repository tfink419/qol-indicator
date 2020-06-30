require 'mapbox-sdk'
require 'geokit'

Mapbox.access_token = ENV["MAPBOX_TOKEN"]

class BuildHeatmapJob < ApplicationJob
  queue_as :build_heatmap

  STEP = 0.001
  LOG_EXP = 1.7

  def perform(build_status, job_retry)
    state = 'received'
    percent = 100
    gstore_count = nil
    current = nil
    south_west = nil
    north_east = nil
    current_transit_type = nil
    lat = nil
    long = nil
    build_status.update!(percent:percent, state:state)
    build_thread = Thread.new {
      begin
        gstore_count = GroceryStore.count
        current = 0
        state = 'isochrones'
        GroceryStore.find_each do |gstore|
          current += 1
          
          isochrones = []
          (1..9).each do |transit_type|
            travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
            no_isochrones = gstore.isochrone_polygons.where(travel_type:travel_type, distance:distance).none?
            if no_isochrones
              isochrone = Mapbox::Isochrone.isochrone(travel_type, "#{gstore[:long]},#{gstore[:lat]}", {contours_minutes: [distance], generalize: 25, polygons:true})
              isochrones << {travel_type:travel_type, distance:distance, polygon:isochrone[0]['features'][0]['geometry']['coordinates'][0]}
            end
          rescue StandardError => err
            pp err
            pp err.backtrace
          end
          gstore.isochrone_polygons.create(isochrones)
        end

        south_west = [abs_floor(GroceryStore.minimum(:lat)-0.3), abs_floor(GroceryStore.minimum(:long))-0.3]
        north_east = [abs_ceil(GroceryStore.maximum(:lat)+0.3), abs_ceil(GroceryStore.maximum(:long)+0.3)]
        lat = south_west[0]


        if job_retry
          lat = HeatmapPoint.maximum(:lat)
        else
          HeatmapPoint.delete_all
        end
        
        state = 'heatmap-points'
        while lat < north_east[0]
          isochrones = []
          (1..9).each do |transit_type|
            long = south_west[1]
            new_heatmaps = []
            current_transit_type = transit_type
            travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
            while long < north_east[1]
              lat_lng = Geokit::LatLng.new(lat, long)
              if (long*10).round == long*10 ## trying to be efficient with gstore and isochrone fetches
                gstore_ids = GroceryStore.select(:id).all_near_point_wide(lat, long, transit_type).map(&:id)
                isochrones = IsochronePolygon.joins('INNER JOIN grocery_stores ON grocery_stores.id = isochrone_polygons.isochronable_id')\
                .select('isochrone_polygons.*', 'grocery_stores.quality AS quality')\
                .where(isochronable_id:gstore_ids, isochronable_type:'GroceryStore', travel_type:travel_type, distance: distance)
              end
              unless gstore_ids.blank?
                qualities = []
                isochrones.each do |isochrone|
                  if isochrone.get_geokit_polygon.contains? lat_lng
                    qualities << isochrone.quality
                  end
                end
                
                quality = log_exp_sum(qualities)
                if(quality > 0)
                  new_heatmaps << {lat: lat, long: long, quality: quality, transit_type:transit_type}
                end
              end
              long = (long+STEP).round(3)
            end
            HeatmapPoint.create(new_heatmaps)
          end
          lat = (lat+STEP).round(3)
        end
        build_status.update!(percent:100, state:'complete')
      rescue StandardError => err
        build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
      end
    }

    while build_thread.alive?
      begin
        GC.start
        if state == 'isochrones'
          percent = (100.0*current/gstore_count).round(2)
        elsif state == 'heatmap-points'
          percent = calc_heatmap_point_percent(current_transit_type, lat, long, south_west, north_east)
        end
        build_status.update!(percent:percent, state:state)
        sleep(5)
      rescue
      end
    end
  end

  private

  def calc_heatmap_point_percent(current_transit_type, lat, long, south_west, north_east)
    lat_percent_per_step = (STEP / (north_east[0]-south_west[0]+STEP))
    (((lat-south_west[0])/(north_east[0]-south_west[0]+STEP) + (long-south_west[1])/(north_east[1]-south_west[1]+STEP)*lat_percent_per_step/9+(current_transit_type-1)*lat_percent_per_step/9)*100).round(3)
  end

  def log_exp_sum(values)
    return 0 if values.blank?
    sum = 0
    values.each do |value|
      sum += LOG_EXP**value
    end
    Math.log(sum, LOG_EXP)
  end
  
  def abs_ceil(num)
    num >= 0 ? num.ceil(1) : num.floor(1)
  end
  
  def abs_floor(num)
    num >= 0 ? num.floor(1) : num.ceil(1)
  end
end
