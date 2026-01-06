class Student::DashboardController < ApplicationController
  before_action :require_student

  def index
    # Các khóa đã mua (đã PAID)
    @purchased_courses = Course
    .joins(course_accesses: :payments)
    .where(course_accesses: { user_id: current_user.id })
    .merge(CourseAccess.active_access)
    .merge(Payment.paid_payments)


    # Các khóa chưa mua
    @new_courses = Course
      .published_courses
      .where.not(id: @purchased_courses.pluck(:id))
  end

  private


  def require_student
    unless current_user&.student_role?
      redirect_to root_path
    end
  end
end
