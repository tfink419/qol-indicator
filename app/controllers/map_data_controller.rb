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

    map_preferences = load_map_preferences

    zoom = params[:zoom].to_i

    if zoom > 12
      zoom = 12
    end
    if zoom < 1
      zoom = 1
    end

    send_data QualityMapService.new(lat_sector, lng_sector, zoom, map_preferences).generate
  end

  def get_grocery_stores
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])

    map_preferences = load_map_preferences

    grocery_stores = CenterQuery.new(TagQuery.new(GroceryStore).query(map_preferences["grocery_store_tags"])).where_in_coordinate_range(south_west, north_east)\
    .limit(10000)\
    .pluck(:id, :lat, :long, :food_quantity)

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

    map_preferences = load_map_preferences
    quality, data = QualityService.new(lat, long, map_preferences).get_quality_data
    render :json => {
      status: 0,
      quality: quality,
      data: data,
      lat:lat.round(4),
      long:long.round(4)
    }
  end

  private

  def load_map_preferences
    MapPreferences.find_by_user_id(session[:user_id]).as_json.merge(JSON.parse(params[:map_preferences]).to_h)
  end
end
