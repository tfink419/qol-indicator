class UsersController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
    render :json => { :status => 0, :users => User.all.map { |user| user.public_attributes }}
  end
end
