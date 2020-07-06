require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  def retrieve_map_data
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])
    gstores = GroceryStore.where_in_coordinate_range(south_west, north_east).limit(1000).pluck(:id, :lat, :long)
    isochrones = []

    transit_type = params[:transit_type] ? params[:transit_type] : User.find(session[:user_id]).map_preferences.transit_type

    zoom = params[:zoom] ? params[:zoom].to_i : 7

    hmp = HeatmapPoint.where(transit_type: transit_type)\
    .where_in_coordinate_range(south_west, north_east, zoom).limit(200000)\
    .order(:lat, :long).pluck(:lat, :long, :quality)

    render :json => { 
      :status => 0,
      :grocery_stores => gstores,
      :heatmap_points => hmp
    }
  end

end
