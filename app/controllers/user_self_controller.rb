class UserSelfController < ApplicationController
  before_action :confirm_logged_in
  def show
    render :json => { 
      :status => 0, 
      :user => User.find(session[:user_id]).public_attributes
    }
  end
  
  def update
    begin
      user = User.find(session[:user_id])
      if params[:user][:password].blank? or user.authenticate(params[:user][:prev_password])
        user.assign_attributes(update_user_self_params)
        if user.save
          render :json =>  {
            :status => 0,
            :message => 'Your Account Updated Successfully.',
            :user => user.public_attributes
          }
        else
          render :json => {:status => 400, :error => 'Your Account Failed to Update.', :error_details => user.errors.messages}, :status => 400
        end
      else
        render :json => {:status => 401, :error => "Incorrect Old Password", :error_details => {:prev_password => ['is incorrect.']}}, :status => 401
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

  private
  
  def update_user_self_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end
