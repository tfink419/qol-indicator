class LoginController < ApplicationController
  def login
    unless session[:user_id].nil?
      redirect_to map_index_path
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
      session[:username] = authorized_user.username
      session[:name] = authorized_user.name
      flash[:notice] = "You are now logged in."
      redirect_to(root_path)
    else
      flash.now[:error] = "Invalid username/password combination."
      render('login')
    end
  end

  def logout
    session[:user_id] = nil
    session[:username] = nil
    flash[:notice] = "Logged Out"
    redirect_to(login_page_path)
  end

  def attempt_register
    @user = User.new(registration_params)
    if @user.save
      session[:user_id] = @user.id
      session[:username] = @user.username
      session[:name] = @user.name
      redirect_to(root_path)
    else
      flash[:error] = @user.errors.full_messages
      redirect_to(register_path)
    end
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end
