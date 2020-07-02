require 'geokit'
require 'mapbox'

Mapbox.access_token = ENV["MAPBOX_TOKEN"]

class BuildHeatmapSegmentJob < ApplicationJob
  queue_as :build_heatmap_segment
  sidekiq_options retry: 0

  LOG_EXP = 1.7

  def perform(build_status)
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    segment = build_status.segment
    state = 'received'
    percent = 100
    gstore_count = nil
    current = nil
    south_west = nil
    north_east = nil
    current_transit_type = nil
    lat = nil
    long = nil
    job_retry ||= build_status.created_at < 15.minutes.ago
    build_status.update!(percent:percent, state:state)
    pp "Segment #{segment}"
    build_thread = Thread.new {
      begin
        Signal.trap('INT') { throw SystemExit }
        Signal.trap('TERM') { throw SystemExit }
        pp 'Starting Thread...'
        gstore_count = segment_part = (GroceryStore.count/BuildHeatmapJob::NUM_SEGMENTS).floor(1)
        segment_low = (segment-1)*segment_part
        segment_low += 1 unless segment == 1
        segment_low = segment_low.round
        
        current = 0
        state = 'isochrones'
        pp 'Isochrones State...'
        GroceryStore.offset(segment_low).limit(segment_part.round).find_each do |gstore|
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

        # Mark as complete and wait for parent job to be done (i.e. all other tasks are complete)
        state = 'isochrones-complete'
        percent = 100
        build_status.update!(state:state, percent:percent);
        sleep(5) until build_status.reload.build_heatmap_status.state == 'heatmap-points'

        south_west = BuildHeatmapJob.furthest_south_west
        north_east =  BuildHeatmapJob.furthest_north_east
        lat = build_status.current_lat

        pp 'Heatmap Points'
        state = 'heatmap-points'
        while true # see towards bottom of loop
          isochrones = []
          (1..9).each do |transit_type|
            long = south_west[1]
            new_heatmaps = []
            current_transit_type = transit_type
            travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
            while long < north_east[1]
              if HeatmapPoint.where(lat:lat, long:long, transit_type:transit_type).none? # Skip all the calculation if point already exists
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
              end
              long = (long+BuildHeatmapJob::STEP).round(BuildHeatmapJob::STEP_PRECISION)
            end
            HeatmapPoint.create(new_heatmaps)
          end
          lat = (build_status.build_heatmap_status.reload.current_lat+BuildHeatmapJob::STEP).round(BuildHeatmapJob::STEP_PRECISION)
          break unless lat <= north_east[0] # essentially while lat <= north_east[0]
          build_status.build_heatmap_status.update!(current_lat:lat)
          build_status.update!(current_lat:lat)
        end
        state = 'complete'
        build_status.update!(percent:100, state:'complete')
      rescue => err
        state = 'error'
        build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
      end
    }

    while build_thread.alive?
      begin
        GC.start
        if state == 'isochrones'
          percent = (100.0*current/gstore_count).round(2)
        elsif state == 'heatmap-points'
          percent = calc_heatmap_point_percent(current_transit_type, long, south_west, north_east)
        elsif state == 'complete' || state == 'error'
          exit
        end
        build_status.update!(percent:percent, state:state, updated_at:Time.now)
        sleep(5)
      rescue
      end
    end
  end

  private

  def calc_heatmap_point_percent(current_transit_type, long, south_west, north_east)
    (((long-south_west[1])/(north_east[1]-south_west[1]+BuildHeatmapJob::STEP)/9+(current_transit_type-1)/9)*100).round(3)
  end

  def log_exp_sum(values)
    return 0 if values.blank?
    sum = 0
    values.each do |value|
      sum += LOG_EXP**value
    end
    Math.log(sum, LOG_EXP)
  end
end
