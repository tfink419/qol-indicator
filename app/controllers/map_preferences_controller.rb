class MapPreferencesController < ApplicationController
  before_action :confirm_logged_in
  def show
    user = User.find(session[:user_id])
    map_preferences = user.map_preferences
    unless map_preferences
      map_preferences = MapPreferences.create(user: user)
      map_preferences.save
    end
    render :json => { 
      :status => 0, 
      :map_preferences => map_preferences.public_attributes
    }
  end
  
  def update
    begin
      user = User.find(session[:user_id])
      map_preferences = user.map_preferences
      unless map_preferences
        map_preferences = MapPreferences.create(user: user)
        map_preferences.save
      end
      if map_preferences.update_attributes(map_preference_params)
        render :json =>  {
          :status => 0,
          :message => 'Your Map Preferences Updated Successfully.',
          :map_preferences => map_preferences.public_attributes
        }
      else
        render :json => {:status => 400, :error => 'Your Map Preferences Failed to Update.', :error_details => map_preferences.errors.messages}, :status => 400
      end
    rescue StandardError => err
      $stderr.print err
      render :json => { 
        :status => 500,
        :error => 'Unknown error occured',
        :error_details => err
      }, :status => 500
    end
  end

  def map_preference_params
    params.require(:map_preferences).permit(:transit_type)
  end
end
