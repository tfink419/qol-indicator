require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  before_action :confirm_logged_in
  def get_quality_map_image
    lat_sector = JSON.parse(params[:lat_sector])
    lng_sector = JSON.parse(params[:lng_sector])

    if lat_sector.blank? || lng_sector.blank?
      render :json => {
        status: 400,
        message: 'Sectors must exist'
      }, status: 400
    end
    
    isochrones = []

    map_preferences = JSON.parse(params[:map_preferences]) if params[:map_preferences]
    map_preferences ||= MapPreferences.find_by_user_id(session[:user_id])

    zoom = params[:zoom].to_i

    if zoom > 10
      zoom = 10
    end
    if zoom < 1
      zoom = 1
    end

    send_data QualityMapService.new(lat_sector, lng_sector, zoom, map_preferences).generate
  end

  def get_grocery_stores
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])

    grocery_stores = GroceryStore.where_in_coordinate_range(south_west, north_east)\
    .limit(10000)\
    .pluck(:id, :lat, :long, :quality)

    render :json => {
      status: 0,
      grocery_stores: grocery_stores
    }
  end

  def get_point_data
    lat = params[:lat].to_f
    long = params[:long].to_f
    unless lat and long
      return render :json => {
        status: 400,
        message: 'Lat and Long must exist'
      }, status: 400
    end

    map_preferences = JSON.parse(params[:map_preferences]) if params[:map_preferences]
    map_preferences ||= MapPreferences.find_by_user_id(session[:user_id])
    quality, data = QualityService.new(lat, long, map_preferences).get_quality_data
    render :json => {
      status: 0,
      quality: quality,
      data: data,
      lat:lat.round(4),
      long:long.round(4)
    }
  end

end
