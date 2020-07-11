require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  def get_heatmap_image
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])

    if south_west.nil? || south_west[0].nil? || south_west[1].nil? || north_east.nil? || north_east[0].nil? || north_east[1].nil?
      render :json => {
        status: 400,
        message: 'South-West and North-East bounds must exist'
      }, status: 400
    end
    
    isochrones = []

    transit_type = params[:transit_type] ? params[:transit_type] : User.find(session[:user_id]).map_preferences.transit_type

    max_zoom = (11-Math.log(north_east[1]-south_west[1], 2)).to_i

    zoom = params[:zoom]&.to_i

    zoom = max_zoom if zoom.nil? || zoom > max_zoom

    fixed_south_west, fixed_north_east, image = HeatmapPoint.generate_image(south_west, north_east, zoom, transit_type)

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

end
