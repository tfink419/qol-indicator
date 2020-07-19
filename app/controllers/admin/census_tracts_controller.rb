require 'json'

class Admin::CensusTractsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:import]
  before_action :confirm_api_key, only: [:import]

  def import
    if params[:census_tracts]
      census_tracts = params.require(:census_tracts).map do |census_tract|
        census_tract.permit!
        census_tract = census_tract.to_hash
        north_bound, east_bound, south_bound, west_bound = PolygonService.get_bounds(census_tract["polygon"])
        census_tract_polygon = {
          polygon:census_tract["polygon"],
          north_bound: north_bound,
          east_bound: east_bound,
          south_bound: south_bound,
          west_bound: west_bound
        }
        census_tract = CensusTract.new(census_tract.extract!("population", "population_density", "land_area", "poverty_percent", "geoid"))
        census_tract.census_tract_polygon =  CensusTractPolygon.new(census_tract_polygon)
        census_tract
      end
      CensusTract.import census_tracts, validate: false, recursive: true
      render :json =>  {
        :status => 0,
        :message => "Import Successful"
      }
    else
      render :json => {:status => 400, :error => 'Error Importing Census Tracts', :error_details => "TODO"}, :status => 400
    end
  end

  private

end
