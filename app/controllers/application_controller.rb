class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  
  private

  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(login_page_path)
    end
  end

  def admin_only
    unless session[:user_id] and User.find(session[:user_id]).admin?
      flash[:notice] = "Admin Access Only"
      redirect_to(map_index_path)
    end
  end
end
