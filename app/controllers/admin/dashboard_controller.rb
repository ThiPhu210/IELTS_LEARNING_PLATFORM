class Admin::DashboardController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @teachers_count = User.teacher_role.count
    @students_count = User.student_role.count
    @admins_count   = User.admin_role.count
    @total_users = User.count
    @courses_count = Course.count
    @lessons_count = Lesson.count
 
  end
end
