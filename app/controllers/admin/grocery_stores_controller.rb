class Admin::GroceryStoresController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    order = params[:order]
    dir = params[:dir]
    search = params[:search]
    if search.nil? or search.blank? or search.length == 1
      gstores, count = IndexQuery.new(GroceryStore).index(limit, offset, order, dir)
    else
      gstores, count = IndexQuery.new(GroceryStore.search(search)).index(limit, offset, order, dir)
    end
    render :json => { 
      :status => 0, 
      :grocery_stores => gstores,
      :grocery_store_count => count
    }
  end

  def show
    render :json => { 
      :status => 0, 
      :grocery_store => GroceryStore.find(params[:id])
    }
  end

  def create
    gstore = GroceryStore.new(grocery_store_params)
    Geocode.new(gstore).attempt_geocode_if_needed
    if gstore.save
      IsochronableChanged.new(gstore, GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP).record
      render :json =>  {
        :status => 0,
        :grocery_store => gstore
      }
    else
      render :json => {:status => 400, :error => 'Error Creating Grocery Store', :error_details => gstore.errors.messages}, :status => 400
    end
  end

  def destroy
    gstore = GroceryStore.find(params[:id])
    IsochronableChanged.new(gstore, GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP).record(true)
    gstore.destroy!

    render :json => { 
      :status => 0, 
      :message => "Grocery Store '#{gstore.name} at #{gstore.address}' successfully deleted."
    }
  end

  def update
    gstore = GroceryStore.find(params[:id])
    gstore.assign_attributes(grocery_store_params)
    Geocode.new(gstore).attempt_geocode_if_needed
    if gstore.save
      IsochronableChanged.new(gstore, GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP).record
      render :json =>  {
        :status => 0,
        :grocery_store => gstore
      }
    else
      render :json => {:status => 400, :error => 'Error Creating Grocery Store', :error_details => gstore.errors.messages}, :status => 400
    end
  end

  def start_upload
    job_status = GroceryStoreUploadStatus.create(state:'initialized', percent:100)
    GroceryStoreUploadJob.perform_later(job_status)
    HerokuWorkersService.new.start if Rails.env == 'production'
    render json: {
      status: 0,
      message: 'Upload Job Initialized',
      grocery_store_upload_status: job_status
    }
  end

  def upload_status_index
    page = params[:page].to_i
    limit = params[:limit].to_i
    offset = page*limit
    job_statuses = GroceryStoreUploadStatus.offset(offset).limit(limit).order(created_at:'DESC')
    upload_status_count = GroceryStoreUploadStatus.count
    newest = GroceryStoreUploadStatus.last
    render json: {
      status: 0,
      grocery_store_upload_statuses: { all:job_statuses, current:(newest && newest.error.nil? && newest.state != 'complete') ? newest : nil },
      grocery_store_upload_status_count: upload_status_count
    }
  end

  def upload_status_show
    render json: {
      status: 0,
      grocery_store_upload_status: GroceryStoreUploadStatus.find(params[:id])
    }
  end

  private

  def grocery_store_params
    params.require(:grocery_store).permit(:name, :address, :city, :state, :zip, :lat, :long, :food_quantity)
  end
end
