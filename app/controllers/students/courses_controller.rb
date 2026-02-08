class Students::CoursesController < ApplicationController
  layout "students"
  before_action :authenticate_user!
  before_action :require_course_access!, only: [:show]

  def index
    courses =
      if params[:paid] == "true"
        Course
          .joins(:course_accesses)
          .merge(current_user.course_accesses.active_status)
          .distinct
      else
        Course.all
      end

    @courses = courses
      .order(created_at: :desc)
      .page(params[:page])
      .per(3)
  end

  def show
    @course = Course.find(params[:id])
  end

  private

  def require_course_access!
    course = Course.find(params[:id])

    unless current_user&.has_course_access?(course)
      redirect_to students_courses_path,
                  alert: "Bạn cần thanh toán để truy cập khóa học"
    end
  end
end
