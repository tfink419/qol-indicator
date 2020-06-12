require 'json'

class MapDataController < ApplicationController
  def retrieve_map_data
    begin
      south_west = JSON.parse(params[:south_west])
      north_east = JSON.parse(params[:north_east])
      gstores = GroceryStore.where_in_coordinate_range(south_west, north_east).limit(1000).map { |gstore| gstore.public_attributes }
      render :json => { 
        :status => 0,
        :grocery_stores => gstores
      }
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end
  
end
