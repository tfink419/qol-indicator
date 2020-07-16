require 'geokit'
require 'quality_map_image'

class BuildHeatmapSegmentJob < ApplicationJob
  queue_as :build_heatmap_segment
  sidekiq_options retry: 0

  def perform(build_status)
    return if build_status.state == 'complete'
    Rails.logger = ActiveRecord::Base.logger = Sidekiq.logger
    
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
          FetchIsochrone.new(gstore).fetch(transit_type_low, transit_type_high)
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
          # TODO: Change to calc lat in chunks of 10 or 100
          lat_height = (lat == north_east_int[0]) ? 1 : BuildHeatmapJob::NUM_STEPS_PER_FUNCTION
          (transit_type_low..transit_type_high).each do |transit_type|
            long = south_west_int[1]
            new_heatmaps = []
            current_transit_type = transit_type
            travel_type, distance = HeatmapPoint::TRANSIT_TYPE_MAP[transit_type]
            while long <= north_east_int[1]
              long_width = (long == north_east_int[1]) ? 1 : BuildHeatmapJob::NUM_STEPS_PER_FUNCTION
              isochrones = IsochronePolygon.joins('INNER JOIN grocery_stores ON grocery_stores.id = isochrone_polygons.isochronable_id')\
              .all_near_point_fat(lat, long, lat_height-1, long_width-1)\
              .where(isochronable_type:'GroceryStore', travel_type:travel_type, distance: distance)\
              .select('isochrone_polygons.polygon', 'grocery_stores.quality AS quality')\
              .map{ |isochrone|
                [
                  isochrone.polygon.map{ |coord| coord.map(&:to_f) },
                  isochrone.quality
                ]
              }
              # skip to next block if none found
              unless isochrones.blank?
                qualities = QualityMapImage.quality_of_points(lat, long, lat_height, long_width, isochrones)
                this_lat = lat
                this_long = long
                new_heatmap_points = qualities.reduce([]) { |arr, quality|
                  if quality > 0
                    arr << [this_lat, this_long, transit_type, quality, HeatmapPoint.precision_of(this_lat, this_long)]
                  end
                  this_long += step_int
                  if this_long%long_width == 0
                    this_long -= step_int*long_width
                    this_lat += step_int
                  end
                  arr
                }
                columns = [:lat, :long, :transit_type, :quality, :precision]
                results = HeatmapPoint.import columns, new_heatmap_points, on_duplicate_key_ignore: true
              end
              long += step_int*long_width
            end
          end
          lat = build_status.build_heatmap_status.reload.current_lat.to_i+step_int*BuildHeatmapJob::NUM_STEPS_PER_FUNCTION
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
