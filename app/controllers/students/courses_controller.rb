class Students::CoursesController < ApplicationController
  layout "students"
  before_action :authenticate_user!
  before_action :require_course_access!, only: [:show]

  # GET /students/courses
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

    if params[:q].present?
      courses = courses.where("title ILIKE ?", "%#{params[:q]}%")
    end

    @courses = courses
      .order(created_at: :desc)
      .page(params[:page])
      .per(3)
    @paid_course_ids = current_user
                        .course_accesses
                        .active_status
                        .pluck(:course_id)
  end

  def show
    @course   = Course.find(params[:id])
    @sections = @course.course_sections
                        .includes(lessons: [speaking_topics: :speaking_questions])
  end

  # GET /students/courses/:id/dashboard  (template cũ của bạn)
  def dashboard
    @course   = Course.find(params[:id])
    @attempts = current_user.speaking_attempts
                            .where(course_id: @course.id)
                            .order(:created_at)
  end

  # ─────────────────────────────────────────────────────────────
  # GET /students/courses/progress  ← ACTION MỚI
  # Tổng quan speaking của toàn bộ khóa học đã mua
  # ─────────────────────────────────────────────────────────────
  def progress
    # 1. Các khóa học student đã có access
    @paid_courses = Course
      .joins(:course_accesses)
      .merge(current_user.course_accesses.active_status)
      .distinct
      .order(:title)

    # 2. Tất cả speaking attempts của user (để vẽ biểu đồ tổng)
    @all_attempts = current_user.speaking_attempts
                                .order(:created_at)

    # 3. Group attempts theo course_id để hiển thị trong từng card
    #    { 5 => [attempt, attempt, ...], 12 => [...], ... }
    @attempts_by_course = @all_attempts.group_by(&:course_id)
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
