require 'geokit'
require 'mapbox'
require 'quality_map_image'

Mapbox.access_token = ENV["MAPBOX_TOKEN"]
ActiveRecord::Base.logger.level = 4 if Rails.env == 'production'
Rails.logger.level = 4 if Rails.env == 'production'

class BuildHeatmapSegmentJob < ApplicationJob
  queue_as :build_heatmap_segment
  sidekiq_options retry: 0

  def perform(build_status)
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    segment = build_status.segment
    state = 'received'
    percent = 100
    gstore_count = nil
    current = nil
    south_west_int = nil
    north_east_int = nil
    current_transit_type = nil
    transit_type_low = nil
    transit_type_high = nil
    lat = nil
    long = nil
    job_retry ||= build_status.created_at < 15.minutes.ago
    build_status.update!(percent:percent, state:state)
    puts "Segment #{segment}"
    build_thread = Thread.new {
      begin
        Signal.trap('INT') { throw SystemExit }
        Signal.trap('TERM') { throw SystemExit }
        puts 'Starting Thread...'
        gstore_count = segment_part = (GroceryStore.count/BuildHeatmapJob::NUM_SEGMENTS).floor(1)
        segment_low = (segment-1)*segment_part
        segment_low += 1 unless segment == 1
        segment_low = segment_low.round
        transit_type_low = build_status.build_heatmap_status.transit_type_low
        transit_type_high = build_status.build_heatmap_status.transit_type_high
        
        current = 0
        state = 'isochrones'
        puts 'Isochrones State...'
        GroceryStore.offset(segment_low).limit(segment_part.round).find_each do |gstore|
          current += 1
          
          isochrones = []
          (transit_type_low..transit_type_high).each do |transit_type|
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

        south_west_int = build_status.build_heatmap_status.south_west
        north_east_int =  build_status.build_heatmap_status.north_east

        step_int = (BuildHeatmapJob::STEP*1000).round.to_i

        lat = build_status.current_lat.to_i

        puts 'Heatmap Points'
        state = 'heatmap-points'
        while true # see towards bottom of loop
          (transit_type_low..transit_type_high).each do |transit_type|
            long = south_west_int[1]
            new_heatmaps = []
            current_transit_type = transit_type
            travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
            while long < north_east_int[1]
              isochrones = IsochronePolygon.joins('INNER JOIN grocery_stores ON grocery_stores.id = isochrone_polygons.isochronable_id')\
              .all_near_point_wide(lat, long)\
              .where(isochronable_type:'GroceryStore', travel_type:travel_type, distance: distance)\
              .pluck('isochrone_polygons.polygon', 'grocery_stores.quality')
              # skip to next block if none found
              unless isochrones.blank?
                qualities = QualityMapImage.quality_of_points(lat, long, 100, isochrones)
                qualities.each{ |quality|
                  if quality > 0
                    begin
                      HeatmapPoint.create(lat:lat, long:long, transit_type: transit_type, quality:quality)
                    rescue
                      # there was probably a race condition on current_lat and then this exact point
                      # this is okay but not great
                    end
                  end
                  long += step_int
                }
              else
                long += step_int*100
              end
              
            end
          end
          lat = build_status.build_heatmap_status.reload.current_lat.to_i+step_int
          break unless lat <= north_east_int[0] # essentially while lat <= north_east_int[0]
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
          percent = calc_heatmap_point_percent(current_transit_type, long, south_west_int, north_east_int, transit_type_low, transit_type_high)
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

  def calc_heatmap_point_percent(current_transit_type, long, south_west_int, north_east_int, transit_type_low, transit_type_high)
    num_transit_types = (transit_type_high-transit_type_low+1).to_f
    (((long-south_west_int[1])/(north_east_int[1]-south_west_int[1]+BuildHeatmapJob::STEP)/num_transit_types+(current_transit_type-transit_type_low)/num_transit_types)*100).round(3)
  end
end
