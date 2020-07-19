class Admin::ApiKeysController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    order = params[:order]
    dir = params[:dir]
    api_keys, api_key_count = IndexQuery.new(ApiKey.where(user_id:session[:user_id])).index(limit, offset, order, dir)
    render :json => { 
      :status => 0, 
      :api_keys => api_keys,
      :api_key_count => api_key_count
    }
  end

  def create
    api_key = ApiKey.generate(session[:user_id])
    if api_key.valid?
      render :json =>  {
        :status => 0,
        :api_key => api_key
      }
    else
      render :json => {:status => 400, :error => 'Create Api Key', :error_details => api_key.errors.messages}, :status => 400
    end
  end

  def show
    render :json => { 
      :status => 0, 
      :api_key => ApiKey.find(key:params[:key])
    }
  end

  def destroy
    api_key = ApiKey.find(params[:key])
    api_key.destroy!

    render :json => { 
      :status => 0, 
      :message => "Api Key '#{api_key.key}' successfully deleted."
    }
  end
end
