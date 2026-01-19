class Students::CoursesController < ApplicationController
  layout "students"
  before_action :authenticate_user!
  before_action :require_course_access!, only: [ :show ]
  def index
    if params[:paid] == "true"
      @courses = Course.joins(:orders)
                       .where(orders: {
                         user_id: current_user.id,
                         status: :paid
                       })
                       .distinct
    else
      @courses = Course.all
    end
  end
  def show
    @course = Course.find(params[:id])
  end
  private

  def require_course_access!
    course = Course.find(params[:id])

    unless current_user&.has_course_access?(course)
      redirect_to students_courses_path, alert: "Bạn cần thanh toán để truy cập khóa học"
    end
  end
end
