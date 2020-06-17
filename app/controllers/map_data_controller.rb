require 'json'

class MapDataController < ApplicationController
  def retrieve_map_data
    south_west = JSON.parse(params[:south_west])
    north_east = JSON.parse(params[:north_east])
    gstores = GroceryStore.where_in_coordinate_range(south_west, north_east).limit(1000).map { |gstore| gstore.public_attributes }
    render :json => { 
      :status => 0,
      :grocery_stores => gstores
    }
  end
  
end
