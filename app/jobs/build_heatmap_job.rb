require 'clipper'
require 'mapbox-sdk'

Mapbox.access_token = ENV["MAPBOX_TOKEN"]

class BuildHeatmapJob < ApplicationJob
  queue_as :build_heatmap

  STEP = 0.001
  LOG_EXP = 1.7

  def perform(build_status)
    state = 'received'
    percent = 100
    gstore_count = nil
    current = nil
    south_west = nil
    north_east = nil
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
            found_isochrones = gstore.isochrone_polygons.where(travel_type:travel_type, distance:distance).count
            if found_isochrones == 0
              isochrone = Mapbox::Isochrone.isochrone(travel_type, "#{gstore[:long]},#{gstore[:lat]}", {contours_minutes: [distance], generalize: 25, polygons:true})
              isochrones << {travel_type:travel_type, distance:distance, polygon:isochrone[0]['features'][0]['geometry']['coordinates'][0]}
            end
          rescue StandardError => err
            pp err
            pp err.backtrace
          end
          gstore.isochrone_polygons.create(isochrones)
        end

        HeatmapPoint.delete_all

        south_west = [abs_floor(GroceryStore.minimum(:lat)-0.2), abs_floor(GroceryStore.minimum(:long))-0.2]
        north_east = [abs_ceil(GroceryStore.maximum(:lat)+0.2), abs_ceil(GroceryStore.maximum(:long)+0.2)]

        c = Clipper::Clipper.new
        lat = south_west[0]
        state = 'heatmap-points'
        while lat < north_east[0]
          long = south_west[1]
          new_heatmaps = []
          isochrones = []
          while long < north_east[1]
            if (long*10).round == long*10 ## trying to be efficient with gstore and isochrone fetches
              gstore_ids = GroceryStore.select(:id).all_near_point_wide(lat, long).map(&:id)
              isochrones = IsochronePolygon.joins('INNER JOIN grocery_stores ON grocery_stores.id = isochrone_polygons.isochronable_id')\
              .select('isochrone_polygons.*', 'grocery_stores.quality AS quality')\
              .where(isochronable_id:gstore_ids, isochronable_type:'GroceryStore')
            end
            unless gstore_ids.blank?
              (1..9).each do |transit_type|
                travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
                qualities = []
                isochrones.each do |isochrone|
                  next unless isochrone.travel_type == travel_type && isochrone.distance == distance
                  if c.pt_in_polygon(long, lat, isochrone.get_polygon_floats)
                    qualities << isochrone.quality
                  end
                end
                
                quality = log_exp_sum(qualities)
                if(quality > 0)
                  new_heatmaps << {lat: lat, long: long, quality: quality, transit_type:transit_type}
                end
              end
            end
            long = (long+STEP).round(3)
          end
          HeatmapPoint.create(new_heatmaps)
          lat = (lat+STEP).round(3)
        end
        build_status.update!(percent:100, state:'complete')
      rescue StandardError => err
        build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
      end
    }

    while build_thread.alive?
      begin
        if state == 'isochrones'
          percent = (100.0*current/gstore_count).round(2)
        elsif state == 'heatmap-points'
          percent = calc_heatmap_point_percent(lat, long, south_west, north_east)
        end
        build_status.update!(percent:percent, state:state)
        sleep(5)
      rescue
      end
    end
  end

  private

  def calc_heatmap_point_percent(lat, long, south_west, north_east)
    lat_percent_per_step = STEP / (north_east[0]-south_west[0]+STEP)
    (((lat-south_west[0])/(north_east[0]-south_west[0]+STEP) + (long-south_west[1])/(north_east[1]-south_west[1]+STEP)*lat_percent_per_step)*100).round(3)
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
    num >= 0 ? num.ceil(3) : num.floor(3)
  end
  
  def abs_floor(num)
    num >= 0 ? num.floor(3) : num.ceil(3)
  end
end
