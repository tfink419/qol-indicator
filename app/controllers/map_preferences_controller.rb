class MapPreferencesController < ApplicationController
  before_action :confirm_logged_in
  def show
    user = User.find(session[:user_id])
    user.create_map_preferences unless user.map_preferences
    render :json => { 
      :status => 0, 
      :map_preferences => user.map_preferences.public_attributes
    }
  end
  
  def update
    user = User.find(session[:user_id])
    map_preferences = MapPreferences.find_by_user_id(session[:user_id])
    map_preferences ||= MapPreferences.create(user_id:session[:user_id])
    if map_preferences.update_attributes(map_preference_params)
      render :json =>  {
        :status => 0,
        :message => 'Your Map Preferences Updated Successfully.',
        :map_preferences => map_preferences.public_attributes
      }
    else
      render :json => {:status => 400, :error => 'Your Map Preferences Failed to Update.', :error_details => map_preferences.errors.messages}, :status => 400
    end
  end

  def map_preference_params
    params.require(:map_preferences).permit(:grocery_store_transit_type,:census_tract_poverty_low,
    :census_tract_poverty_high,:grocery_store_ratio,:census_tract_poverty_ratio, :grocery_store_tags)
  end
end
