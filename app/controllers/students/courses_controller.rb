# app/controllers/students/courses_controller.rb
class Students::CoursesController < ApplicationController
  layout "students"

  # landing page là PUBLIC (không cần đăng nhập)
  before_action :authenticate_user!, except: [:landing]
  before_action :set_course, only: [:landing, :show, :dashboard]
  before_action :require_course_access!, only: [:show, :dashboard]

  # ────────────────────────────────────────────
  # GET /students/courses
  # ────────────────────────────────────────────
  def index
    courses =
      if params[:paid] == "true"
        Course.joins(:course_accesses)
              .merge(current_user.course_accesses.active_status)
              .distinct
      else
        Course.all
      end

    courses = courses.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    @courses         = courses.order(created_at: :desc).page(params[:page]).per(3)
    @paid_course_ids = current_user.course_accesses.active_status.pluck(:course_id)
  end

  # ────────────────────────────────────────────
  # GET /students/courses/:id          ← LANDING (public)
  #
  # Nếu đã đăng nhập + đã mua → redirect vào nội dung học
  # Ngược lại → trang giới thiệu khóa học + nút thanh toán
  # ────────────────────────────────────────────
  def landing
    if user_signed_in? && current_user.has_course_access?(@course)
      redirect_to dashboard_students_course_path(@course) and return
    end

    @sections        = @course.course_sections.includes(:lessons)
    @total_lessons   = @sections.sum { |s| s.lessons.count }
    @teacher_profile = @course.respond_to?(:teacher_profile) ? @course.teacher_profile : nil
  end

  # ────────────────────────────────────────────
  # GET /students/courses/:id/dashboard  ← NỘI DUNG HỌC (cần access)
  # Đây là cái show.html.erb cũ (LMS view)
  # ────────────────────────────────────────────
  def show
    @sections = @course.course_sections
                       .includes(lessons: [speaking_topics: :speaking_questions])
  end

  # Giữ nguyên route member :dashboard nếu bạn đang dùng
  def dashboard
    @attempts = current_user.speaking_attempts
                            .where(course_id: @course.id)
                            .order(:created_at)
  end

  # ────────────────────────────────────────────
  # GET /students/courses/progress
  # ────────────────────────────────────────────
  def progress
    @paid_courses = Course
      .joins(:course_accesses)
      .merge(current_user.course_accesses.active_status)
      .distinct
      .order(:title)

    @all_attempts       = current_user.speaking_attempts.order(:created_at)
    @attempts_by_course = @all_attempts.group_by(&:course_id)
  end

  private

  def set_course
    @course = Course.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to students_courses_path, alert: "Không tìm thấy khóa học."
  end

  def require_course_access!
    return if current_user&.has_course_access?(@course)

    redirect_to landing_students_course_path(@course),
                alert: "Bạn cần thanh toán để truy cập khóa học này."
  end
end
