class UsersController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only, :except => [:show_current]

  def index
    begin
      page = params[:page].to_i
      limit = params[:limit].to_i
      offset = page*limit
      order = (User.attribute_names.include? params[:order]) ? params[:order] : 'created_at'
      dir = (['ASC', 'DESC'].include? params[:dir]) ? params[:dir] : 'ASC'
      render :json => { 
        :status => 0, 
        :users => User.offset(offset).limit(limit).order("#{order} #{dir}").map { |user| user.public_attributes },
        :user_count => User.count
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

  def show_current
    render :json => { 
      :status => 0, 
      :user => User.find(session[:user_id])
    }
  end

  def show
    render :json => { 
      :status => 0, 
      :user => User.find(params[:id])
    }
  end

  def destroy
    begin
      if params[:id].to_i == session[:user_id]
        render :json => { 
          :status => 403, 
          :error => "Can not delete yourself.",
          :error_details => "Current user id is the same as the id of user that was attempted to be deleted."
        }, :status => 403
      else
        user = User.find(params[:id])
        user.delete

        render :json => { 
          :status => 0, 
          :message => "User '#{user.username}' successfully deleted."
        }
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

  def update
    begin
      user = User.find(params[:id])
      if params[:id].to_i == session[:user_id] and ActiveRecord::Type::Boolean.new.cast(params[:user][:is_admin]) != user.is_admin
        render :json => { 
          :status => 403, 
          :error => "Can not change your own admin status.",
          :error_details => "User attempted to change is_admin flag of thier own User model."
        }, :status => 403
      else
        user = User.find(params[:id])
        if user.update_attributes(update_user_params)
          session[:user_id] = user.id
          render :json =>  {
            :status => 0,
            :message => 'Update User Successful',
            :user => user.public_attributes
          }
        else
          render :json => {:status => 401, :error => 'Update User Failed', :error_details => user.errors.messages}
        end
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
  def admin_create_user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :is_admin, :password, :password_confirmation)
  end
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :is_admin)
  end
end
