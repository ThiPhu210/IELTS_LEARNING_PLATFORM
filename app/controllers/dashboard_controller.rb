class DashboardController < ApplicationController
  before_action :authenticate_user!

  def redirect
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
