class BuildHeatmapController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def build
    build_status = BuildHeatmapStatus.create(state:'initialized', percent:100)
    BuildHeatmapJob.perform_later(build_status)
    render json: {
      status: 0,
      message: 'Heatmap Build Job Initialized',
      build_heatmap_status:build_status
    }
  end

  def status_index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    build_statuses = BuildHeatmapStatus.offset(offset).limit(limit).order(created_at:'DESC')
    build_heatmap_status_count = BuildHeatmapStatus.count
    newest = BuildHeatmapStatus.last
    current = nil
    current = newest if newest && !newest.complete?
    render json: {
      status: 0,
      build_heatmap_statuses: { all:build_statuses, current:current},
      build_heatmap_status_count: build_heatmap_status_count
    }
  end

  def status_show
    render json: {
      status: 0,
      build_heatmap_status: BuildHeatmapStatus.find(params[:id])
    }
  end
end
