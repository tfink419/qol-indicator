class AdminController < ApplicationController
  before_action :confirm_logged_in
  before_action :admin_only

  def index
  end
end
