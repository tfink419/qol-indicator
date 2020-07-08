class GroceryStoresController < ApplicationController
  before_action :confirm_logged_in
  def show
    render :json => { 
      :status => 0, 
      :grocery_store => GroceryStore.find(params[:id]).public_attributes
    }
  end
end
