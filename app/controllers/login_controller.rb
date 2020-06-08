class LoginController < ApplicationController
  def login
    unless session[:user_id].nil?
      redirect_to root_path
    end
  end
  
  def attempt_login
    puts request.format
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
        :user => {
          :id => authorized_user.id,
          :username => authorized_user.username,
          :email => authorized_user.email,
          :first_name => authorized_user.first_name,
          :last_name => authorized_user.last_name,
          :is_admin => authorized_user.is_admin
        }
      }
    else
      render :json => {:status => 1, :error => "Invalid username/password combination."}
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
        :user => {
          :id => @user.id,
          :username => @user.username,
          :email => @user.email,
          :first_name => @user.first_name,
          :last_name => @user.last_name,
          :is_admin => @user.is_admin
        }
      }
    else
      render :json => {:status => 1, :error => 'Registration Failed', :error_details => @user.errors.messages}
    end
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end
