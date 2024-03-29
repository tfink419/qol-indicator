class BuildQualityMapJob < ApplicationJob
  queue_as :build_quality_map
  sidekiq_options retry: 0

  NUM_SEGMENTS=(ENV['NUM_HEATMAP_THREADS'] || 9).to_i
  NUM_SHRINK_SEGMENTS=(ENV['NUM_SHRINK_THREADS'] || 29).to_i

  def perform(build_status, job_retry=false)
    @build_status = build_status
    return unless @build_status && BuildQualityMapStatus.most_recent
    if @build_status.id != BuildQualityMapStatus.most_recent.id
      return BuildQualityMapJob.set(wait: 15.seconds).perform_later(@build_status, job_retry)
    end
    @actually_ran = true
    Rails.logger = ActiveRecord::Base.logger = Sidekiq.logger    
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    job_retry ||= !(['initialized', 'received', 'branching'].include? @build_status.state)

    @build_status.update!(state:'received', percent:100)
    point_type = @build_status.point_type.constantize

    @south_west_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(@build_status.south_west))
    @north_east_sector = MapSector.new(DataImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(@build_status.north_east))
    @build_status.update!(state:'branching', percent:100)
    puts "Branching"
    # dont reset lat and try workers if this is a retry and lat already exists
    unless job_retry && @build_status.current_lat
      HerokuWorkersService.new(NUM_SEGMENTS+1).start
      current_sector = @south_west_sector
      until((count = @build_status.segment_statuses.count) >= NUM_SEGMENTS)
        build_segment_status = @build_status.segment_statuses.create(
          state:'initialized',
          percent:100,
          segment:count+1,
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

    # in case its different due to an old build and a change in num_segments
    @num_segments_this_build = @build_status.segment_statuses.count

    puts "Waiting Isochrones"
    until @build_status.reload.segment_statuses.all?(&:atleast_isochrones_state?)
      sleep(5)
      @build_status.update!(percent:@build_status.segment_statuses.count(&:atleast_isochrones_state?)*100/@num_segments_this_build, updated_at:Time.now)
    end

    return if error_found
    
    @build_status.update!(state:'isochrones', percent:0)
    puts "Waiting Isochrones complete"
    until @build_status.reload.segment_statuses.all?(&:atleast_isochrones_complete_state?)
      sleep(5)
      @build_status.update!(percent:(@build_status.segment_statuses.sum { |segment_status| segment_status.percent/@num_segments_this_build }).round(3), updated_at:Time.now)
    end

    return if error_found
    

    unless @build_status.reload.segment_statuses.all?(&:atleast_waiting_shrink_state?)
      DataImageCuda.new.purge_queues
      GoogleWorkersService.new.check!
      @build_status.update!(state:'quality-map-points', percent:0)
      puts "Waiting Quality Map Points Complete"
    end

    until @build_status.reload.segment_statuses.all?(&:atleast_waiting_shrink_state?)
      sleep(5)
      @build_status.update!(
        percent:calc_total_quality_map_percent,
        updated_at:Time.now
      )
    end

    unless job_retry
      HerokuWorkersService.new(NUM_SEGMENTS*2+1).start
    end

    GoogleWorkersService.new.stop
    return if error_found

    # HerokuWorkersService.new(NUM_SHRINK_SEGMENTS+1).start
    # until((count = @build_status.segment_statuses.count) >= NUM_SHRINK_SEGMENTS)
    #   build_segment_status = @build_status.segment_statuses.create(
    #     state:'waiting-shrink',
    #     segment:count+1,
    #     percent:0
    #   )
    #   BuildQualityMapSegmentJob.perform_later(build_segment_status)
    # end

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
        state:'shrink',
        current_zoom:zoom,
        percent:0
      )
      puts "Waiting Shrink"

      until @build_status.reload.segment_statuses.all? { |segment_status|
        segment_status.complete? || (segment_status.waiting_shrink_state? && segment_status.current_zoom == zoom)
      }
        sleep(5)
        @build_status.update!(
          percent:calc_total_quality_map_percent,
          updated_at:Time.now
        )
      end
      return if error_found
    end

    puts "Complete"
    @build_status.update!(percent:100, state:'complete')
  rescue Exception => err
    puts "Errored out"
    @build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
  ensure
    if @actually_ran
      HerokuWorkersService.new.stop unless BuildQualityMapStatus.most_recent
      GoogleWorkersService.new.stop
    end
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
    long_percent = @build_status.segment_statuses.sum { |segment_status|
      segment_status.atleast_quality_map_state? ? segment_status.percent : 0 # 0 if not yet in the right state
    }
    lat_percent_per_step = (0.01 / (@north_east_sector.lat_sector-@south_west_sector.lat_sector+1))
    ((
      (@build_status.current_lat_sector-NUM_SEGMENTS-@south_west_sector.lat_sector+1).to_f/
        (@north_east_sector.lat_sector-@south_west_sector.lat_sector+1)+
        long_percent*lat_percent_per_step)*
        100).round(3)
  end
end
