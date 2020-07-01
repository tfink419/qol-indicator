Mapbox.access_token = ENV["MAPBOX_TOKEN"]

class BuildHeatmapJob < ApplicationJob
  queue_as :build_heatmap
  sidekiq_options retry: 0

  NUM_SEGMENTS=10

  def perform(build_status, job_retry=false)
    begin
      build_status.update!(state:'received', percent:100)

      unless job_retry
        HeatmapPoint.delete_all
      end
      
      build_status.update!(state:'branching', percent:100)

      (1..NUM_SEGMENTS).each do |segment|
        if build_status.build_heatmap_segment_statuses.where(segment:segment).none?
          build_segment_status = build_status.build_heatmap_segment_statuses.create(state:'initialized', percent:100, segment:segment)
          BuildHeatmapSegmentJob.perform_later(build_segment_status, job_retry)
        end
      end

      until build_status.reload.build_heatmap_segment_statuses.all?(&:atleast_isochrones_state?)
        sleep(5)
        build_status.build_heatmap_segment_statuses.reload
      end

      return if error_found(build_status)
      
      build_status.update!(state:'isochrones', percent:0)

      until build_status.reload.build_heatmap_segment_statuses.reload.all?(&:atleast_isochrones_complete_state?)
        sleep(5)
        build_status.update!(state:'ioschrones', percent:(build_status.build_heatmap_segment_statuses.sum { |segment_status| segment_status.percent/NUM_SEGMENTS }).round(3))
      end

      return if error_found(build_status)

      build_status.update!(state:'heatmap-points', percent:0)

      until build_status.reload.build_heatmap_segment_statuses.all? { |segment_status| segment_status.error ||  segment_status.state == 'complete' } 
        sleep(5)
        build_status.update!(state:'heatmap-points', percent:(build_status.build_heatmap_segment_statuses.sum { |segment_status| segment_status.percent/NUM_SEGMENTS }).round(3))
      end
      return if error_found(build_status)
      build_status.update!(percent:100, state:'complete')
    rescue StandardError => err
      build_status.update!(error: "#{err.message}:\n#{err.backtrace}")
    end
  end

  private

  def error_found(build_status)
    errored = build_status.build_heatmap_segment_statuses.where.not(error:nil).first
    if errored
      build_status.update!(error: errored.error)
    end
    errored
  end
end
