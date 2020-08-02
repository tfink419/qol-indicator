class Admin::BuildQualityMapController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def build
    point_type = params[:point_type]
    point_type ||= "GroceryStoreFoodQuantityMapPoint"
    case point_type
    when "GroceryStoreFoodQuantityMapPoint"
      transit_type_high = GroceryStore::NUM_TRANSIT_TYPES
      polygon_class_service = PolygonClassService.new(IsochronePolygon.where(isochronable_type:'GroceryStore'))
      south_west = polygon_class_service.furthest_south_west
      if south_west[0]
        north_east = polygon_class_service.furthest_north_east
      else
        south_west = [GroceryStore.minimum(:lat)-0.5, GroceryStore.minimum(:long)-0.5]
        north_east = [GroceryStore.maximum(:lat)+0.5, GroceryStore.maximum(:long)+0.5]
      end
    when "CensusTractPovertyMapPoint"
      polygon_class_service = PolygonClassService.new(CensusTractPolygon)
      south_west = polygon_class_service.furthest_south_west
      north_east = polygon_class_service.furthest_north_east
      transit_type_high = 1
    else
      return render json: {
        status: 400,
        message: 'Bad Point Type'
      }, status: 400
    end
    build_status = BuildQualityMapStatus.create(state:'initialized',
      percent:100,
      south_west:south_west,
      north_east:north_east,
      transit_type_low:1,
      transit_type_high:GroceryStore::NUM_TRANSIT_TYPES,
      point_type:point_type
    )
    BuildQualityMapJob.perform_later(build_status)
    HerokuWorkersService.new.start if Rails.env == 'production'
    render json: {
      status: 0,
      message: 'Quality Map Build Job Initialized',
      build_quality_map_status:build_status
    }
  end

  def status_index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    build_statuses = BuildQualityMapStatus.offset(offset).limit(limit).order(created_at:'DESC')
    build_quality_map_status_count = BuildQualityMapStatus.count
    current = BuildQualityMapStatus.most_recent
    render json: {
      status: 0,
      build_quality_map_statuses: { all:build_statuses, current:current},
      build_quality_map_status_count: build_quality_map_status_count
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
        build_quality_map_status: BuildQualityMapStatus.find(params[:id]).as_json(:include => :segment_statuses)
      }
    end
  end
end
