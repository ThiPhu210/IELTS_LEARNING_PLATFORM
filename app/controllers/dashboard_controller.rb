class DashboardController < ApplicationController
  before_action :authenticate_user!

  def redirect
    case current_user.role
    when "admin"
      redirect_to admin_dashboard_path
    when "student"
      redirect_to students_dashboard_path
    else
      redirect_to root_path
    end
  end
end
