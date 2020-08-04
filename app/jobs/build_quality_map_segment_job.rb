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
    job_retry ||= build_status.created_at < 15.minutes.ago
    build_status.update!(percent:100, state:'received')
    puts "Segment #{segment}"
    gstore_count = segment_part = (GroceryStore.count/BuildQualityMapJob::NUM_SEGMENTS).floor(1)
    segment_low = (segment-1)*segment_part
    segment_low += 1 unless segment == 1
    segment_low = segment_low.round
    transit_type_low = build_status.parent_status.transit_type_low
    transit_type_high = build_status.parent_status.transit_type_high
    point_type = build_status.parent_status.point_type

    case point_type
    when 'GroceryStoreFoodQuantityMapPoint'
      point_class = GroceryStoreFoodQuantityMapPoint
      polygon_class = IsochronePolygon
      parent_class = GroceryStore
      parent_class_id = "isochronable_id"
      quality_column_name = "food_quantity"
      extra_params = [:transit_type, :tags]
      num_tags = GroceryStore::TAG_GROUPS.length
      isochrone_type = true
    when 'CensusTractPovertyMapPoint'
      point_class = CensusTractPovertyMapPoint
      polygon_class = CensusTractPolygon
      parent_class = CensusTract
      parent_class_id = "census_tract_id"
      quality_column_name = "poverty_percent"
      extra_params = []
      num_tags = 1
      isochrone_type = false
    end

    # Isochrone only points
    if isochrone_type
      current = 0
      build_status.update!(percent:0, state:'isochrones')
      puts 'Isochrones State...'
      before = Time.now
      GroceryStore.offset(segment_low).limit(segment_part.round).find_each do |gstore|
        current += 1
        if Time.now-before > 5
          before = Time.now
          build_status.update!(percent:(100.0*current/gstore_count).round(2))
        end
        FetchIsochrone.new(gstore, GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP).fetch(transit_type_low, transit_type_high)
      end

      # Mark as complete and wait for parent job to be done (i.e. all other tasks are complete)
      build_status.update!(state:'isochrones-complete', percent:100)
      sleep(5) until build_status.reload.parent_status.state == 'quality-map-points'
    end

    @south_west_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.parent_status.south_west))
    @north_east_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.parent_status.north_east))
    image_service = DataImageService.new(point_class::SHORT_NAME, @south_west_sector.zoom)
    current_sector = MapSector.from_sectors(
      DataImageService::DATA_CHUNK_SIZE,
      build_status.current_lat_sector,
      @south_west_sector.lng_sector
    )
    @lat_sector = current_sector.lat_sector
    puts 'Quality Map Points'
    build_status.update!(percent:0, state:'quality-map-points', updated_at:Time.now)
    while true # see towards bottom of loop
      puts "Lat Sector: #{@lat_sector}"
      while current_sector.lng_sector <= @north_east_sector.lng_sector
        (transit_type_low..transit_type_high).each do |transit_type|
          (0...num_tags).each do |tag_num|
            TagQuery.new(GroceryStore).all_calcs_in_tag(tag_num).each do |tag_calc_num|
              if num_tags == 1
                parent_query = {
                  name:parent_class.name,
                  table_name:parent_class.table_name,
                  query:'all'
                }
              else
                parent_query = TagQuery.new(parent_class).query(tag_calc_num, true)
              end
              new_quality_maps = []
              if point_type == 'GroceryStoreFoodQuantityMapPoint'
                travel_type, distance = GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP[transit_type]
              end
              polygons = PolygonQuery.new(polygon_class, parent_query, parent_class_id, quality_column_name).
              all_near_bounds_with_parent(
                current_sector.south,
                current_sector.west,
                current_sector.north,
                current_sector.east,
                travel_type,
                distance
              )
              # skip to next block if none found
  
              added_params = extra_params.map do |param|
                case param
                when :transit_type
                  transit_type
                when :tags
                  tag_calc_num
                end
              end
              unless polygons.blank?
                create_and_save_data_image(
                  image_service,
                  current_sector,
                  polygons,
                  point_class,
                  parent_class,
                  added_params
                )
              end
            end
          end
        end
        current_sector = current_sector.next_lng_sector
        @lng_sector = current_sector.lng_sector
        build_status.update!(
          percent:calc_grocery_store_quality_map_point_percent
        )
      end
      @lat_sector = build_status.parent_status.reload.current_lat_sector.to_i+1
      break unless @lat_sector <= @north_east_sector.lat_sector # essentially while lat <= north_east_int[0]
      current_sector = MapSector.from_sectors(
        DataImageService::DATA_CHUNK_SIZE,
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
    puts "Building Initial Points Complete"
    build_status.update!(percent:100, state:'waiting-subsample')
    sleep(5) until build_status.reload.parent_status.state == 'subsample'
    
    current_sector = MapSector.from_sectors(
      DataImageService::DATA_CHUNK_SIZE,
      build_status.current_lat_sector,
      @south_west_sector.zoom_out.lng_sector,
      @south_west_sector.zoom-1
    )
    @lat_sector = current_sector.lat_sector
    @lng_sector = current_sector.lng_sector

    puts 'Subsampling'
    (0...@south_west_sector.zoom).reverse_each do |zoom|
      @south_west_sector = @south_west_sector.zoom_out
      @north_east_sector = @north_east_sector.zoom_out
      build_status.update!(
        current_lat:@south_west_sector.south,
        current_lat_sector:@lat_sector,
        state:'subsample',
        current_zoom:zoom,
        percent: 0
      )
      puts "Starting lat_sector #{@lat_sector}"
      while true # see towards bottom of loop
        puts "Zoom: #{zoom}, Lat Sector: #{@lat_sector}"
        while current_sector.lng_sector <= @north_east_sector.lng_sector
          (transit_type_low..transit_type_high).each do |transit_type|
            (0...num_tags).each do |tag_num|
              TagQuery.new(GroceryStore).all_calcs_in_tag(tag_num).each do |tag_calc_num|
                added_params = extra_params.map do |param|
                  case param
                  when :transit_type
                    transit_type
                  when :tags
                    tag_calc_num
                  end
                end
                north_west, north_east, south_west, south_east = current_sector.zoom_in.map do |sector|
                  DataImageService.new(point_class::SHORT_NAME, zoom+1).
                  load(added_params, sector.lat_sector, sector.lng_sector)
                end
                
                image = QualityMapImage.subsample4(DataImageService::DATA_CHUNK_SIZE, north_west, north_east, south_west, south_east)
                if image
                  DataImageService.new(point_class::SHORT_NAME, zoom)
                  .save(
                    added_params,
                    current_sector.lat_sector,
                    current_sector.lng_sector,
                    image
                  )
                end
              end
            end
            current_sector = current_sector.next_lng_sector
            @lng_sector = current_sector.lng_sector
            build_status.update!(
              percent:calc_grocery_store_quality_map_point_percent
            )
          end
        end
        @lat_sector = build_status.parent_status.reload.current_lat_sector.to_i+1
        break unless @lat_sector <= @north_east_sector.lat_sector # essentially while lat <= north_east_int[0]
        current_sector = MapSector.from_sectors(
          DataImageService::DATA_CHUNK_SIZE,
          @lat_sector,
          @south_west_sector.lng_sector,
          zoom
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

      build_status.update!(percent:100, state:'waiting-subsample')
      until zoom == 0 || (build_status.reload.parent_status.state == 'subsample' &&
        build_status.parent_status.current_zoom == zoom-1)
        sleep(5)
      end
      current_sector = MapSector.from_sectors(
        DataImageService::DATA_CHUNK_SIZE,
        build_status.current_lat_sector,
        @south_west_sector.zoom_out.lng_sector,
        zoom-1
      )
      @lat_sector = current_sector.lat_sector
      @lng_sector = current_sector.lng_sector
    end
    puts "Complete"
    build_status.update!(percent:100, state:'complete')

  rescue => err
    puts "Errored out"
    build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
  end

  private

  def create_and_save_data_image(image_service, current_sector, polygons, point_class, parent_class, added_params)
    value_image = QualityMapImage.quality_of_points_image(
      MapPoint::STEP_INVERT,
      current_sector.south_step,
      current_sector.west_step,
      DataImageService::DATA_CHUNK_SIZE,
      polygons,
      point_class::SCALE,
      parent_class::QUALITY_CALC_METHOD,
      parent_class::QUALITY_CALC_VALUE
    )
    image_service.save(
      added_params,
      current_sector.lat_sector,
      current_sector.lng_sector,
      value_image
    )
  end

  def calc_grocery_store_quality_map_point_percent
    ((@lng_sector-@south_west_sector.lng_sector).to_f/
      (@north_east_sector.lng_sector-@south_west_sector.lng_sector+1).to_f*100).round(3)
  end
end
