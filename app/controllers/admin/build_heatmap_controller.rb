class Admin::BuildHeatmapController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def build
    south_west = GroceryStore.furthest_south_west
    north_east = GroceryStore.furthest_north_east
    south_west_int = south_west.map { |val| (val*1000).round.to_i }
    north_east_int = north_east.map { |val| (val*1000).round.to_i }
    build_status = BuildHeatmapStatus.create(state:'initialized', percent:100,
    rebuild:params[:rebuild], south_west:south_west_int, north_east:north_east_int,
    transit_type_low:1, transit_type_high:GroceryStore::NUM_TRANSIT_TYPES)
    BuildHeatmapJob.perform_later(build_status)
    HerokuWorkersService.start
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
    current = BuildHeatmapStatus.most_recent
    render json: {
      status: 0,
      build_heatmap_statuses: { all:build_statuses, current:current},
      build_heatmap_status_count: build_heatmap_status_count
    }
  end

  def status_show
    if params[:id] == 'undefined'
      render json: {
        status: 400,
        message: 'Missing Id'
      }, status: 400
    else
      render json: {
        status: 0,
        build_heatmap_status: BuildHeatmapStatus.find(params[:id]).as_json(:include => :build_heatmap_segment_statuses)
      }
    end
  end
end
