require 'securerandom'

class LoginController < ApplicationController
  def login
    unless session[:user_id].nil?
      redirect_to root_path
    end
  end
  
  def attempt_login
    if params[:username].present? && params[:password].present?
      found_user = User.where(:username => params[:username]).first
      if found_user
        authorized_user = found_user.authenticate(params[:password])
      end
    end
    if authorized_user
      session[:user_id] = authorized_user.id
      render :json =>  {
        :status => 0,
        :user => authorized_user
      }
    else
      render :json => {:status => 401, :error => "Invalid username/password combination."}, :status => 401
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged Out"
    redirect_to(login_page_path)
  end

  def attempt_register
    @user = User.new(registration_params)
    if @user.save
      session[:user_id] = @user.id
      render :json =>  {
        :status => 0,
        :user => @user
      }
    else
      render :json => {:status => 401, :error => 'Registration Failed', :error_details => @user.errors.messages}, :status => 401
    end
  end

  def forgot_password
    user = User.where(:email => params[:email]).first
    render :json => {:status => 200, :error => 'Password Forgetted', :uuid => SecureRandom.uuid}
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end
