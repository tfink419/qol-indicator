require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  before_action :confirm_logged_in
  def get_quality_map_image
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])

    if south_west.nil? || south_west[0].nil? || south_west[1].nil? || north_east.nil? || north_east[0].nil? || north_east[1].nil?
      render :json => {
        status: 400,
        message: 'South-West and North-East bounds must exist'
      }, status: 400
    end
    
    isochrones = []

    map_preferences = JSON.parse(params[:map_preferences]) if params[:map_preferences]
    map_preferences ||= MapPreferences.find_by_user_id(session[:user_id])

    max_zoom = (11-Math.log(north_east[1]-south_west[1], 2)).to_i

    zoom = params[:zoom]&.to_i

    zoom = max_zoom if zoom.nil? || zoom > max_zoom

    fixed_south_west, fixed_north_east, image = QualityMapService.new(south_west, north_east, zoom, map_preferences).generate

    response.headers['Content-Range'] = "Coordinates #{fixed_south_west}-#{fixed_north_east}"
    send_data image
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
    lat = params[:lat]
    long = params[:long]
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
      lat: (lat.to_f*1000).round/1000.0,
      long: (long.to_f*1000).round/1000.0
    }
  end

end
