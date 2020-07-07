require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  def get_heatmap_image
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])
    isochrones = []

    transit_type = params[:transit_type] ? params[:transit_type] : User.find(session[:user_id]).map_preferences.transit_type

    zoom = params[:zoom] ? params[:zoom].to_i : 7

    fixed_south_west, fixed_north_east, image = HeatmapPoint.generate_image(south_west, north_east, zoom, transit_type)

    puts "bounds: #{fixed_south_west}-#{fixed_north_east}"

    response.headers['Content-Range'] = "Coordinates #{fixed_south_west}-#{fixed_north_east}"
    send_data image.to_blob
  end

  def get_grocery_stores
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])

    grocery_stores = GroceryStore.where_in_coordinate_range(south_west, north_east).limit(1000).pluck(:id, :lat, :long)

    render :json => {
      status: 0,
      grocery_stores: grocery_stores
    }
  end

end
