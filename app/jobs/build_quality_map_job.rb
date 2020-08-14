class BuildQualityMapJob < ApplicationJob
  class NoSuchPointTypeError < StandardError; end
  queue_as :build_quality_map
  sidekiq_options retry: 0

  NUM_SEGMENTS=(ENV['NUM_HEATMAP_THREADS'] || 8).to_i

  def perform(build_status, job_retry=false)
    @build_status = build_status
    return unless @build_status && BuildQualityMapStatus.most_recent
    if @build_status.id != BuildQualityMapStatus.most_recent.id
      return BuildQualityMapJob.set(wait: 15.seconds).perform_later(@build_status, job_retry)
    end
    Rails.logger = ActiveRecord::Base.logger = Sidekiq.logger    
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    job_retry ||= !(['initialized', 'received', 'branching'].include? @build_status.state)

    case @build_status.point_type
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
      num_tags = 0
      isochrone_type = false
    else
      throw NoSuchPointTypeError.new("Invalid Point Type Given")
    end

    transit_type_low = @build_status.transit_type_low
    transit_type_high = @build_status.transit_type_high

    @build_status.update!(state:'received', percent:100) if @build_status.state == 'initialized'

    @south_west_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(@build_status.south_west))
    @north_east_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(@build_status.north_east))
    # dont reset lat and try workers if this is a retry and lat already exists

    if %w(received isochrones).include?(@build_status.state)
      @build_status.update!(percent:100, state:'received')

      # Isochrone only points
      if isochrone_type
        parent_class_count = parent_class.count
        current = 0
        build_status.update!(percent:0, state:'isochrones')
        puts 'Isochrones State...'
        before = Time.now
        parent_class.find_each do |parent|
          current += 1
          if Time.now-before > 5
            before = Time.now
            build_status.update!(percent:(100.0*current/parent_class_count).round(2))
          end
          FetchIsochrone.new(parent, point_class::TRANSIT_TYPE_MAP).fetch(transit_type_low, transit_type_high)
        end

        # Mark as complete and wait for parent job to be done (i.e. all other tasks are complete)
      end
    end

    current_sector = @south_west_sector
    if %w(received isochrones quality-map-points).include?(@build_status.state)
      dic = DataImageCuda.new
      puts "Building Quality Points"
      @lat_sector = current_sector.lat_sector
      @lng_sector = current_sector.lng_sector
      build_status.update!(percent:0, state:'quality-map-points')
      loop do # see towards bottom of loop
        puts "Lat Sector: #{@lat_sector}"
        while current_sector.lng_sector <= @north_east_sector.lng_sector
          (transit_type_low..transit_type_high).each do |transit_type|
            (0..num_tags).each do |tag_num|
              next if num_tags != 0 && tag_num == num_tags
              TagQuery.new(parent_class).all_calcs_in_tag(tag_num).each do |tag_calc_num|
                if num_tags == 0
                  parent_query = {
                    name:parent_class.name,
                    table_name:parent_class.table_name,
                    query:'all'
                  }
                else
                  parent_query = TagQuery.new(parent_class).query(tag_calc_num, true)
                end
                new_quality_maps = []
                if @build_status.point_type == 'GroceryStoreFoodQuantityMapPoint'
                  travel_type, distance = GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP[transit_type]
                end
                unless PolygonQuery.new(polygon_class, parent_query, parent_class_id, quality_column_name).
                    all_near_bounds_with_parent(
                      current_sector.south,
                      current_sector.west,
                      current_sector.north,
                      current_sector.east,
                      travel_type,
                      distance
                    ).any?
                  polygon_query = PolygonQuery.new(polygon_class, parent_query, parent_class_id, quality_column_name).
                  all_near_bounds_with_parent(
                    current_sector.south,
                    current_sector.west,
                    current_sector.north,
                    current_sector.east,
                    travel_type,
                    distance,
                    true # Raw
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
                  url = DataImageService.new(point_class::SHORT_NAME, current_sector.zoom).
                    presigned_url_put(added_params, current_sector.lat_sector, current_sector.lng_sector)
                  id = dic.queue(
                    current_sector.south_step,
                    current_sector.west_step,
                    MapPoint::STEP_INVERT,
                    DataImageService::DATA_CHUNK_SIZE,
                    point_class::SCALE,
                    parent_class::QUALITY_CALC_METHOD,
                    parent_class::QUALITY_CALC_VALUE,
                    url,
                    polygon_query
                  )
                end
              end
            end
          end
          current_sector = current_sector.next_lng_sector
          @lng_sector = current_sector.lng_sector
          @lng_percent = (@lng_sector-@south_west_sector.lng_sector).to_f /
            (@north_east_sector.lng_sector-@south_west_sector.lng_sector+1)
          build_status.update!(
            percent:calc_total_quality_map_percent
          )
        end
        break unless @lat_sector < @north_east_sector.lat_sector # essentially while lat <= north_east_int[0]
        current_sector = MapSector.from_sectors(
          DataImageService::DATA_CHUNK_SIZE,
          @lat_sector += 1,
          @lng_sector = @south_west_sector.lng_sector
        )
        @lng_percent = 0
        build_status.update!(
          current_lat:current_sector.south,
          current_lat_sector:@lat_sector,
          percent:calc_total_quality_map_percent
        )
      end
    end
    
    if @build_status.state == 'quality-map-points'
      puts "Branching"
      HerokuWorkersService.new(NUM_SEGMENTS+1).start
      @build_status.update!(state:'branching', percent:100)
      unless job_retry && @build_status.current_lat
        if @build_status.segment_statuses.none?
          current_sector = @south_west_sector
          (1..NUM_SEGMENTS).each do |segment|
            build_segment_status = @build_status.segment_statuses.create(
              state:'initialized',
              percent:100,
              segment:segment,
              current_lat:current_sector.south,
              current_lat_sector:current_sector.lat_sector
            )
            BuildQualityMapSegmentJob.perform_later(build_segment_status)
            current_sector = current_sector.next_lat_sector
          end
          current_sector = current_sector.prev_lat_sector
          @build_status.update!(
            current_lat:current_sector.south,
            current_lat_sector:current_sector.lat_sector
          )
        end
      end
    end

    return if error_found

    (0...@south_west_sector.zoom).reverse_each do |zoom|
      @south_west_sector = @south_west_sector.zoom_out
      @north_east_sector = @north_east_sector.zoom_out
      current_sector = @south_west_sector
      @build_status.segment_statuses.each do |segment_status|
        segment_status.update!(
          current_lat:current_sector.south,
          current_lat_sector:current_sector.lat_sector
        )
        current_sector = current_sector.next_lat_sector
      end
      current_sector = current_sector.prev_lat_sector
      @build_status.update!(
        current_lat:current_sector.south,
        current_lat_sector:current_sector.lat_sector,
        state:'subsample',
        current_zoom:zoom,
        percent:0
      )
      puts "Waiting Subsample"

      until @build_status.reload.segment_statuses.all? { |segment_status|
        segment_status.complete? || (segment_status.waiting_subsample_state? && segment_status.current_zoom == zoom)
      }
        sleep(5)
        @lng_percent = @build_status.segment_statuses.sum { |segment_status|
          segment_status.atleast_waiting_subsample_state? ? (segment_status.percent/@num_segments_this_build) : 0 # 0 if not yet in the right state
        }
        @build_status.update!(
          percent:calc_total_quality_map_percent,
          updated_at:Time.now
        )
      end
      return if error_found
    end

    puts "Complete"
    @build_status.update!(percent:100, state:'complete')
  rescue => err
    puts "Errored out"
    @build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
  ensure
    HerokuWorkersService.new(NUM_SEGMENTS+1).stop
  end

  private

  def error_found
    errored = @build_status.segment_statuses.reload.where.not(error:nil).first
    if errored
      @build_status.update!(error: errored.error)
    end
    errored
  end

  def calc_total_quality_map_percent
    lat_percent_per_step = (0.01 / (@north_east_sector.lat_sector-@south_west_sector.lat_sector+1))
    ((
      (@build_status.current_lat_sector-@south_west_sector.lat_sector).to_f/
        (@north_east_sector.lat_sector-@south_west_sector.lat_sector+1)+
        @lng_percent*lat_percent_per_step)*
        100).round(3)
  end
end
