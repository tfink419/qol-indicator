class BuildQualityMapJob < ApplicationJob
  queue_as :build_quality_map
  sidekiq_options retry: 0

  NUM_SEGMENTS=(ENV['NUM_HEATMAP_THREADS'] || 8).to_i

  def perform(build_status, job_retry=false)
    return unless build_status
    if build_status.id != BuildQualityMapStatus.most_recent.id
      return BuildQualityMapJob.set(wait: 15.seconds).perform_later(build_status, job_retry)
    end
    Rails.logger = ActiveRecord::Base.logger = Sidekiq.logger    
    begin
      Signal.trap('INT') { throw SystemExit }
      Signal.trap('TERM') { throw SystemExit }
      job_retry ||= !(['initialized', 'received', 'branching'].include? build_status.state)

      build_status.update!(state:'received', percent:100)
      point_type = build_status.point_type.constantize

      south_west_sector = MapSector.new(QualityImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.south_west))
      north_east_sector = MapSector.new(QualityImageService::DATA_CHUNK_SIZE, MapPoint.from_coords(build_status.north_east))
      build_status.update!(state:'branching', percent:100)
      puts "Branching"
      # dont reset lat and try workers if this is a retry and lat already exists
      unless job_retry && build_status.current_lat
        if build_status.segment_statuses.none?
          (1..NUM_SEGMENTS).each do |segment|
            build_segment_status = build_status.segment_statuses.create(
              state:'initialized',
              percent:100,
              segment:segment,
              current_lat:south_west_sector.south,
              current_lat_sector:south_west_sector.lat_sector
            )
            BuildQualityMapSegmentJob.perform_later(build_segment_status)
            south_west_sector = south_west_sector.next_lat_sector
          end
        end
        south_west_sector = south_west_sector.prev_lat_sector
        build_status.update!(
          current_lat:south_west_sector.south,
          current_lat_sector:south_west_sector.lat_sector
        )
      end

      # in case its different due to an old build and a change in num_segments
      num_segments_this_build = build_status.segment_statuses.count

      puts "Waiting Isochrones"
      until build_status.reload.segment_statuses.all?(&:atleast_isochrones_state?)
        sleep(5)
        build_status.update!(percent:build_status.segment_statuses.count(&:atleast_isochrones_state?)*100/num_segments_this_build, updated_at:Time.now)
      end

      return if error_found(build_status)
      
      build_status.update!(state:'isochrones', percent:0)
      puts "Waiting Isochrones complete"

      until build_status.reload.segment_statuses.all?(&:atleast_isochrones_complete_state?)
        sleep(5)
        build_status.update!(percent:(build_status.segment_statuses.sum { |segment_status| segment_status.percent/num_segments_this_build }).round(3), updated_at:Time.now)
      end

      return if error_found(build_status)
      
      build_status.update!(state:'quality-map-points', percent:0)
      puts "Waiting Complete"

      until build_status.reload.segment_statuses.all? { |segment_status| segment_status.error ||  segment_status.state == 'complete' } 
        sleep(5)
        build_status.update!(
          percent:calc_total_quality_map_percent(
            build_status,
            num_segments_this_build,
            south_west_sector,
            north_east_sector
            ),
          updated_at:Time.now
        )
      end
      return if error_found(build_status)
      puts "Complete"
      build_status.update!(percent:100, state:'complete')
    rescue => err
      puts "Errored out"
      build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
    end
  end

  def self.floor(val)
  end

  private

  def error_found(build_status)
    errored = build_status.segment_statuses.reload.where.not(error:nil).first
    if errored
      build_status.update!(error: errored.error)
    end
    errored
  end

  def calc_total_quality_map_percent(build_status, num_segments, south_west_sector, north_east_sector)
    long_percent = build_status.segment_statuses.sum { |segment_status|
      segment_status.atleast_quality_map_state? ? (segment_status.percent/num_segments) : 0 # 0 if not yet in the right state
    }
    lat_percent_per_step = (0.01 / (north_east_sector.lat_sector-south_west_sector.lat_sector+1))
    ((
      (build_status.current_lat_sector-south_west_sector.lat_sector).to_f/
        (north_east_sector.lat_sector-south_west_sector.lat_sector+1)+
        long_percent*lat_percent_per_step)*
        100).round(3)
  end
end
