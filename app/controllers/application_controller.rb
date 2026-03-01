class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_no_cache

  def after_sign_in_path_for(resource)
    # Nếu user đến từ trang khóa học (return_to param), quay về đó
    stored = stored_location_for(resource)
    return stored if stored.present?

    # Fallback: điều hướng theo role
    case resource.role
    when "admin"   then admin_dashboard_path
    when "student" then students_dashboard_path
    else root_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,          keys: [:full_name, :school])
    devise_parameter_sanitizer.permit(:account_update,   keys: [:full_name, :school])
    devise_parameter_sanitizer.permit(:sign_in,          keys: [:remember_me])
  end

  private

  def set_no_cache
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"]        = "no-cache"
    response.headers["Expires"]       = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
