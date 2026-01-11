class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login 
    unless session[:user_id] 
      redirect_to login_path 
    end
  end

  def require_admin
    redirect_to dashboard_path unless current_user&.admin_role?
  end

  private
  def disable_cache
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
