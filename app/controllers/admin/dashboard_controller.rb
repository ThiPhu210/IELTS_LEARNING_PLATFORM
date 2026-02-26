class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # ── User stats ──────────────────────────────────────────
    @students_count  = User.where(role: :student).count
    @admins_count    = User.where(role: :admin).count
    @total_users     = User.count

    # ── Course stats ─────────────────────────────────────────
    @courses_count   = Course.count
    @active_courses  = Course.where(status: :active).count
    @lessons_count   = Lesson.count
    @sections_count  = CourseSection.count

    # ── Speaking stats ───────────────────────────────────────
    @attempts_count  = SpeakingAttempt.count
    @avg_band        = SpeakingAttempt.where.not(overall_band: nil).average(:overall_band)&.round(1)

    # ── Order / Revenue stats ────────────────────────────────
    @orders_count    = Order.count
    @paid_orders     = Order.where(status: 1).count
    @total_revenue   = Payment.where(status: 1).sum(:amount)
    @pending_orders  = Order.where(status: 0).count

    # ── Enrollments (course_accesses) ────────────────────────
    @enrollments_count  = CourseAccess.count
    @active_enrollments = CourseAccess.where(status: 1).count

    # ── Recent activity ──────────────────────────────────────
    @recent_students = User.where(role: :student).order(created_at: :desc).limit(5)
    @recent_orders   = Order.includes(:user, :course).order(created_at: :desc).limit(5)
    @recent_attempts = SpeakingAttempt.includes(:user).where.not(overall_band: nil)
                                      .order(created_at: :desc).limit(5)

    # ── Top courses by enrollment ────────────────────────────
    @top_courses = Course.left_joins(:course_accesses)
                         .group("courses.id")
                         .order("COUNT(course_accesses.id) DESC")
                         .select("courses.*, COUNT(course_accesses.id) AS enrollments_count")
                         .limit(5)

    # ── Chart data ───────────────────────────────────────────
    adapter = ActiveRecord::Base.connection.adapter_name
    years   = [Time.current.year, Time.current.year - 1]
    @months = Date::MONTHNAMES[1..12]

    group_by_month = if adapter == "SQLite"
      "CAST(strftime('%m', created_at) AS INTEGER)"
    else
      "EXTRACT(MONTH FROM created_at)"
    end

    @chart_data   = {}
    @revenue_data = {}
    @attempts_data = {}

    years.each do |year|
      counts = User.where(role: :student)
                   .where(created_at: Time.new(year).all_year)
                   .group(group_by_month).count
                   .transform_keys(&:to_i)
      @chart_data[year] = (1..12).map { |m| counts[m] || 0 }
    end

    year = Time.current.year
    rev = Payment.where(status: 1)
                 .where(created_at: Time.new(year).all_year)
                 .group(group_by_month).sum(:amount)
                 .transform_keys(&:to_i)
    @revenue_data = (1..12).map { |m| (rev[m] || 0).to_i }

    att = SpeakingAttempt.where(created_at: Time.new(year).all_year)
                         .group(group_by_month).count
                         .transform_keys(&:to_i)
    @attempts_data = (1..12).map { |m| att[m] || 0 }

    @current_year = Time.current.year
  end
end
