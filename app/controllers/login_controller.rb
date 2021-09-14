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
    redirect_to(root_path)
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
    user = User.find_by_email(params[:email])
    pass_reset = user.password_resets.create(:uuid => SecureRandom.uuid, :expires_at => 1.day.from_now)
    pass_reset.save
    PasswordResetMailer.with(uuid: pass_reset.uuid, email: user.email, username: user.username).send_reset_password.deliver_now
    render :json => {:status => 200, :message => 'Reset Password Email Sent'}
  end

  def reset_password
    pass_reset = PasswordReset.find_by_uuid(params[:uuid])
    if pass_reset
      if pass_reset.expires_at < DateTime.now
        pass_reset.destroy!
      else
        user = pass_reset.user
        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]
        if user.save
          pass_reset.destroy!
          return render :json => {:status => 200, :message => 'Password Reset'}
        else
          return render :json => {:status => 401, :error => 'Registration Failed', :error_details => user.errors.messages}, :status => 401
        end
      end
    end
    render :json => {:status => 401, :error => 'Invalid Reset Code'}, :status => 401
  end

  def reset_password_details
    pass_reset = PasswordReset.find_by_uuid(params[:uuid])
    if pass_reset
      if pass_reset.expires_at < DateTime.now
        pass_reset.destroy!
      else
        return render :json => {:status => 200, :username => pass_reset.user.username}
      end
    end
    render :json => {:status => 404, :error => 'Invalid Reset Code'}, :status => 404
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end
end
