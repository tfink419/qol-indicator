def abs_ceil(num)
  num >= 0 ? num.ceil(1) : num.floor(1)
end

def abs_floor(num)
  num >= 0 ? num.floor(1) : num.ceil(1)
end

class BuildHeatmapJob < ApplicationJob
  queue_as :build_heatmap
  sidekiq_options retry: 0

  NUM_SEGMENTS=(ENV['NUM_HEATMAP_THREADS'] || 8).to_i
  STEP_PRECISION=3
  STEP=(0.1**STEP_PRECISION).round(STEP_PRECISION) # 0.001

  def perform(build_status, job_retry=false)
    begin
      Signal.trap('INT') { throw SystemExit }
      Signal.trap('TERM') { throw SystemExit }
      job_retry ||= build_status.created_at < 15.minutes.ago
      build_status.update!(state:'received', percent:100)

      HeatmapPoint.delete_all if build_status.rebuild? && !job_retry
      
      build_status.update!(state:'branching', percent:100)

      south_west = furthest_south_west_local
      north_east = furthest_north_east_local
      # dont reset lat and try workers if this is a retry and lat already exists
      unless job_retry && build_status.current_lat
        lat = south_west[0]
        if build_status.build_heatmap_segment_statuses.none?
          (1..NUM_SEGMENTS).each do |segment|
            build_segment_status = build_status.build_heatmap_segment_statuses.create(state:'initialized', percent:100, segment:segment, current_lat:lat)
            BuildHeatmapSegmentJob.perform_later(build_segment_status)
            lat = (lat+STEP).round(STEP_PRECISION)
          end
        end
        build_status.update!(current_lat:(lat-STEP).round(STEP_PRECISION))
      end

      # in case its different due to an old build and a change in num_segments
      num_segments_this_build = build_status.build_heatmap_segment_statuses.count

      until build_status.reload.build_heatmap_segment_statuses.all?(&:atleast_isochrones_state?)
        sleep(5)
        build_status.update!(percent:build_status.build_heatmap_segment_statuses.count(&:atleast_isochrones_state?)*100/num_segments_this_build, updated_at:Time.now)
      end

      return if error_found(build_status)
      
      build_status.update!(state:'isochrones', percent:0)

      until build_status.reload.build_heatmap_segment_statuses.reload.all?(&:atleast_isochrones_complete_state?)
        sleep(5)
        build_status.update!(percent:(build_status.build_heatmap_segment_statuses.sum { |segment_status| segment_status.percent/num_segments_this_build }).round(3), updated_at:Time.now)
      end

      return if error_found(build_status)

      build_status.update!(state:'heatmap-points', percent:0)

      until build_status.reload.build_heatmap_segment_statuses.all? { |segment_status| segment_status.error ||  segment_status.state == 'complete' } 
        sleep(5)
        build_status.update!(percent:calc_total_heatmap_percent(build_status, num_segments_this_build, south_west, north_east), updated_at:Time.now)
      end
      return if error_found(build_status)
      build_status.update!(percent:100, state:'complete')
    rescue => err
      build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
    end
  end

  def self.furthest_south_west
    [abs_floor(GroceryStore.minimum(:lat)-0.3), abs_floor(GroceryStore.minimum(:long))-0.3]
  end

  def self.furthest_north_east
    [abs_ceil(GroceryStore.maximum(:lat)+0.3), abs_ceil(GroceryStore.maximum(:long)+0.3)]
  end

  private

  def furthest_south_west_local
    [abs_floor(GroceryStore.minimum(:lat)-0.3), abs_floor(GroceryStore.minimum(:long))-0.3]
  end

  def furthest_north_east_local
    [abs_ceil(GroceryStore.maximum(:lat)+0.3), abs_ceil(GroceryStore.maximum(:long)+0.3)]
  end

  def error_found(build_status)
    errored = build_status.build_heatmap_segment_statuses.where.not(error:nil).first
    if errored
      build_status.update!(error: errored.error)
    end
    errored
  end

  def calc_total_heatmap_percent(build_status, num_segments, south_west, north_east)
    long_percent = build_status.build_heatmap_segment_statuses.sum { |segment_status|
      segment_status.atleast_heatmap_state? ? (segment_status.percent/num_segments) : 0 # 0 if not yet in the right state
    }
    lat_percent_per_step = (STEP / (north_east[0]-south_west[0]+STEP))
    (((build_status.current_lat-south_west[0])/(north_east[0]-south_west[0]+STEP)+long_percent*lat_percent_per_step)*100).round(3)
  end
end
