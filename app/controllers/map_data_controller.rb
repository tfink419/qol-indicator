require 'json'
# require 'httplog'

class MapDataController < ApplicationController
  def retrieve_map_data
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])
    gstores = GroceryStore.where_in_coordinate_range(south_west, north_east).limit(1000)
    isochrones = []

    transit_type = params[:transit_type] ? params[:transit_type] : User.find(session[:user_id]).map_preferences.transit_type

    hmp = HeatmapPoint.where(transit_type: transit_type).where_in_coordinate_range(south_west, north_east, params[:zoom]).limit(100000)
    pp hmp.count

    render :json => { 
      :status => 0,
      :grocery_stores => gstores.pluck(:id, :lat, :long),
      :heatmap_points => hmp.pluck(:lat, :long, :quality)
    }
  end

end
