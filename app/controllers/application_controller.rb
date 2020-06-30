class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  rescue_from StandardError do |err|
    $stderr.print err
    $stderr.print err.backtrace
    render :json => { 
      :status => 500,
      :error => 'Unknown error occured',
      :error_details => err
    }, :status => 500
  end
  
  private

  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(login_page_path)
    end
  end

  def admin_only
    unless session[:user_id] and User.find(session[:user_id]).admin?
      unless request.format.json?
        flash[:error] = "Admin Access Only"
        redirect_to(map_index_path)
      end
      render :json => {:status => 403, :error => 'Admin Access Only'}, :status => 403
    end
  end
end
