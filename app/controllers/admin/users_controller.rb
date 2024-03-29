class Admin::UsersController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    order = params[:order]
    dir = params[:dir]
    users, user_count = IndexQuery.new(User).index(limit, offset, order, dir)
    render :json => { 
      :status => 0, 
      :users => users,
      :user_count => user_count
    }
  end

  def create
    @user = User.new(admin_create_user_params)
    if @user.save
      @user.create_map_preferences
      render :json =>  {
        :status => 0,
        :user => @user
      }
    else
      render :json => {:status => 400, :error => 'Create User', :error_details => @user.errors.messages}, :status => 400
    end
  end

  def show
    render :json => { 
      :status => 0, 
      :user => User.find(params[:id])
    }
  end

  def destroy
    if params[:id].to_i == session[:user_id]
      render :json => { 
        :status => 403, 
        :error => "Can not delete yourself.",
        :error_details => "Current user id is the same as the id of user that was attempted to be deleted."
      }, :status => 403
    else
      user = User.find(params[:id])
      user.destroy!

      render :json => { 
        :status => 0, 
        :message => "User '#{user.username}' successfully deleted."
      }
    end
  end

  def update
    user = User.find(params[:id])
    user.assign_attributes(update_user_params)
    if params[:id].to_i == session[:user_id] and user.is_admin_changed?
      render :json => { 
        :status => 403, 
        :error => "Can not change your own admin status.",
        :error_details => "User attempted to change is_admin flag of thier own User model."
      }, :status => 403
    else
      if user.save
        render :json =>  {
          :status => 0,
          :message => 'Update User Successful',
          :user => user
        }
      else
        render :json => {:status => 400, :error => 'Update User Failed', :error_details => user.errors.messages}, :status => 400
      end
    end
  end

  private
  def admin_create_user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :is_admin, :password, :password_confirmation)
  end
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :is_admin)
  end
end
