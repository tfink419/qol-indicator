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
    @state = 'received'
    @percent = 100
    job_retry ||= build_status.created_at < 15.minutes.ago
    build_status.update!(percent:@percent, state:@state)
    puts "Segment #{segment}"
    @gstore_count = segment_part = (GroceryStore.count/BuildQualityMapJob::NUM_SEGMENTS).floor(1)
    segment_low = (segment-1)*segment_part
    segment_low += 1 unless segment == 1
    segment_low = segment_low.round
    @transit_type_low = build_status.parent_status.transit_type_low
    @transit_type_high = build_status.parent_status.transit_type_high
    point_type = build_status.parent_status.point_type

    case point_type
    when 'GroceryStoreQualityMapPoint'
      point_class = GroceryStoreQualityMapPoint
      polygon_class = IsochronePolygon
      parent_class = GroceryStore
      parent_class_id = "isochronable_id"
      quality_column_name = "quality"
      extra_params = [:transit_type]
      isochrone_type = true
    when 'CensusTractPovertyMapPoint'
      point_class = CensusTractPovertyMapPoint
      polygon_class = CensusTractPolygon
      parent_class = CensusTract
      parent_class_id = "census_tract_id"
      quality_column_name = "poverty_percent"
      extra_params = []
      isochrone_type = false
    end

    # Isochrone only points
    if isochrone_type
      @current = 0
      @state = 'isochrones'
      build_status.update!(percent:0, state:@state)
      puts 'Isochrones State...'
      before = Time.now
      GroceryStore.offset(segment_low).limit(segment_part.round).find_each do |gstore|
        @current += 1
        if Time.now-before > 5
          before = Time.now
          build_status.update!(percent:(100.0*current/gstore_count).round(2), state:@state)
        end
        FetchIsochrone.new(gstore).fetch(@transit_type_low, @transit_type_high)
      end

      # Mark as complete and wait for parent job to be done (i.e. all other tasks are complete)
      @state = 'isochrones-complete'
      @percent = 100
      build_status.update!(state:@state, percent:@percent)
      sleep(5) until build_status.reload.parent_status.state == 'quality-map-points'
    end

    @south_west_sector = MapSector.new(QualityImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.parent_status.south_west))
    @north_east_sector = MapSector.new(QualityImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.parent_status.north_east))
    image_service = QualityImageService.new(point_class::SHORT_NAME, @south_west_sector.zoom)
    current_sector = MapSector.from_sectors(
      QualityImageService::DATA_CHUNK_SIZE,
      build_status.current_lat_sector,
      @south_west_sector.lng_sector
    )
    @lat_sector = current_sector.lat_sector
    puts 'Quality Map Points'
    @state = 'quality-map-points'
    build_status.update!(percent:0, state:@state, updated_at:Time.now)
    while true # see towards bottom of loop
      puts "Lat Sector: #{@lat_sector}"
      (@transit_type_low..@transit_type_high).each do |transit_type|
        new_quality_maps = []
        @current_transit_type = transit_type
        if point_type == 'GroceryStoreQualityMapPoint'
          travel_type, distance = GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP[transit_type]
        end
        while current_sector.lng_sector <= @north_east_sector.lng_sector
          polygons = PolygonQuery.new(polygon_class, parent_class, parent_class_id, quality_column_name).
          all_near_bounds_with_parent(current_sector.south, current_sector.west, current_sector.north, current_sector.east, travel_type, distance)
          # skip to next block if none found
          unless polygons.blank?
            value_image = QualityMapImage.quality_of_points_image(
              MapPoint::STEP_INVERT,
              current_sector.south,
              current_sector.west,
              QualityImageService::DATA_CHUNK_SIZE,
              QualityImageService::DATA_CHUNK_SIZE,
              polygons,
              point_class::SCALE,
              parent_class::QUALITY_CALC_METHOD,
              parent_class::QUALITY_CALC_VALUE
            )
            added_params = extra_params.map do |param|
              case param
              when :transit_type
                transit_type
              end
            end
            image_service.save_quality_image(
              added_params,
              current_sector.lat_sector,
              current_sector.lng_sector,
              value_image
            )
          end
          current_sector = current_sector.next_lng_sector
          @lng_sector = current_sector.lng_sector
          build_status.update!(
            current_lat:current_sector.south,
            current_lat_sector:@lat_sector,
            percent:calc_grocery_store_quality_map_point_percent
          )
        end
      end
      @lat_sector = build_status.parent_status.reload.current_lat_sector.to_i+1
      break unless @lat_sector <= @north_east_sector.lat_sector # essentially while lat <= north_east_int[0]
      current_sector = MapSector.from_sectors(
        QualityImageService::DATA_CHUNK_SIZE,
        @lat_sector,
        @south_west_sector.lng_sector
      )
      @lng_sector = current_sector.lng_sector
      build_status.parent_status.update!(
        current_lat:current_sector.south,
        current_lat_sector:@lat_sector
      )
      build_status.update!(
        current_lat:current_sector.south,
        current_lat_sector:@lat_sector,
        percent:calc_grocery_store_quality_map_point_percent
      )
    end
    puts "Complete"
    @state = 'complete'
    build_status.update!(percent:100, state:'complete')
  rescue => err
    @state = 'error'
    puts "Errored out"
    build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
  end

  private

  def calc_grocery_store_quality_map_point_percent
    num_transit_types = (@transit_type_high-@transit_type_low+1).to_f
    (((@lng_sector-@south_west_sector.lng_sector).to_f/
      (@north_east_sector.lng_sector-@south_west_sector.lng_sector+1).to_f/
      num_transit_types+(@current_transit_type-@transit_type_low).to_f/num_transit_types)*100).round(3)
  end
end
