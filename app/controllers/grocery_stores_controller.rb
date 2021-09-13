class GroceryStoresController < ApplicationController
  def show
    render :json => {
      :status => 0,
      :grocery_store => GroceryStore.find(params[:id]).public_attributes
    }
  end
end
