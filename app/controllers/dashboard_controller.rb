class DashboardController < ApplicationController
  before_action :require_login
  before_action :disable_cache

  def index
    case current_user.role
    when "admin"
      redirect_to admin_dashboard_path
    when "teacher"
      redirect_to teacher_dashboard_path
    else
      redirect_to student_dashboard_path
    end
  end
end
