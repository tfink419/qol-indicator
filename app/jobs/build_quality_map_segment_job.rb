require 'quality_map_image'

class BuildQualityMapSegmentJob < ApplicationJob
  queue_as :build_quality_map_segment
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
        gstore_count = segment_part = (GroceryStore.count/BuildQualityMapJob::NUM_SEGMENTS).floor(1)
        segment_low = (segment-1)*segment_part
        segment_low += 1 unless segment == 1
        segment_low = segment_low.round
        transit_type_low = build_status.parent_status.transit_type_low
        transit_type_high = build_status.parent_status.transit_type_high
        point_type = build_status.parent_status.point_type

        if point_type == 'GroceryStoreQualityMapPoint'
          point_class = GroceryStoreQualityMapPoint
          polygon_class = IsochronePolygon
          parent_class = GroceryStore
          parent_class_id = "isochronable_id"
          quality_column_name = "quality"
          quality_calc_method = GroceryStore::QUALITY_CALC_METHOD
          quality_calc_value = GroceryStore::QUALITY_CALC_VALUE
          include_transit_type = true
          isochrone_type = true
        elsif point_type == 'CensusTractPovertyMapPoint'
          point_class = CensusTractPovertyMapPoint
          polygon_class = CensusTractPolygon
          parent_class = CensusTract
          parent_class_id = "census_tract_id"
          quality_column_name = "poverty_percent"
          quality_calc_method = CensusTract::QUALITY_CALC_METHOD
          quality_calc_value = CensusTract::QUALITY_CALC_VALUE
          include_transit_type = false
          isochrone_type = false
        end

        # Isochrone only points
        if isochrone_type
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
          sleep(5) until build_status.reload.parent_status.state == 'quality-map-points'
        end

        south_west_int = build_status.parent_status.south_west.map { |coord_part| coord_part.floor(1-BuildQualityMapJob::STEP_PRECISION) }
        north_east_int = build_status.parent_status.north_east.map { |coord_part| coord_part.ceil(1-BuildQualityMapJob::STEP_PRECISION) }

        step_int = (BuildQualityMapJob::STEP*1000).round.to_i

        lat = build_status.current_lat.to_i

        puts 'Quality Map Points'
        state = 'quality-map-points'
        while true # see towards bottom of loop
          lat_height = (lat == north_east_int[0]) ? 1 : BuildQualityMapJob::NUM_STEPS_PER_FUNCTION
          (transit_type_low..transit_type_high).each do |transit_type|
            long = south_west_int[1]
            new_quality_maps = []
            current_transit_type = transit_type
            if point_type == 'GroceryStoreQualityMapPoint'
              travel_type, distance = GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP[transit_type]
            end
            while long <= north_east_int[1]
              long_width = (long == north_east_int[1]) ? 1 : BuildQualityMapJob::NUM_STEPS_PER_FUNCTION
              polygons = PolygonQuery.new(polygon_class, parent_class, parent_class_id, quality_column_name)\
              .all_near_point_fat_with_parent(lat, long, lat_height, long_width, travel_type, distance)
              # skip to next block if none found
              unless polygons.blank?
                qualities = QualityMapImage.quality_of_points(lat, long, lat_height, long_width, polygons, quality_calc_method, quality_calc_value)
                this_lat = lat
                this_long = long
                new_map_points = qualities.reduce([]) do |arr, quality|
                  if quality > 0
                    if include_transit_type
                      arr << [this_lat, this_long, transit_type, quality, MapPointService.precision_of(this_lat, this_long)]
                    else
                      arr << [this_lat, this_long, quality, MapPointService.precision_of(this_lat, this_long)]
                    end
                  end
                  this_long += step_int
                  if this_long%long_width == 0
                    this_long -= step_int*long_width
                    this_lat += step_int
                  end
                  arr
                end
                if include_transit_type
                  columns = [:lat, :long, :transit_type, :value, :precision]
                else
                  columns = [:lat, :long, :value, :precision]
                end
                results = point_class.import columns, new_map_points, on_duplicate_key_ignore: true
              end
              long += step_int*long_width
            end
          end
          lat = build_status.parent_status.reload.current_lat.to_i+step_int*BuildQualityMapJob::NUM_STEPS_PER_FUNCTION
          break unless lat <= north_east_int[0] # essentially while lat <= north_east_int[0]
          build_status.parent_status.update!(current_lat:lat)
          build_status.update!(current_lat:lat)
        end
        puts "Complete"
        state = 'complete'
        build_status.update!(percent:100, state:'complete')
      rescue => err
        state = 'error'
        puts "Errored out"
        build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
      end
    }

    while build_thread.alive?
      begin
        GC.start
        if state == 'isochrones'
          percent = (100.0*current/gstore_count).round(2)
        elsif state == 'quality-map-points'
          percent = calc_grocery_store_quality_map_point_percent(current_transit_type, long, south_west_int, north_east_int, transit_type_low, transit_type_high)
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

  def calc_grocery_store_quality_map_point_percent(current_transit_type, long, south_west_int, north_east_int, transit_type_low, transit_type_high)
    num_transit_types = (transit_type_high-transit_type_low+1).to_f
    (((long-south_west_int[1])/(north_east_int[1]-south_west_int[1]+BuildQualityMapJob::STEP)/num_transit_types+(current_transit_type-transit_type_low)/num_transit_types)*100).round(3)
  end
end
