class Admin::DashboardController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :disable_cache

  def index
    @teachers_count = User.teacher_role.count
    @students_count = User.student_role.count
    @admins_count   = User.admin_role.count
    @total_users    = User.count
    @courses_count  = Course.count
    @lessons_count  = Lesson.count


    adapter = ActiveRecord::Base.connection.adapter_name
    years = [Time.current.year, Time.current.year - 1]
    @months = Date::MONTHNAMES[1..12]
    @chart_data = {}

    group_by_month =
      if adapter == "SQLite"
        "CAST(strftime('%m', created_at) AS INTEGER)"
      else
        "EXTRACT(MONTH FROM created_at)"
      end

    years.each do |year|
      counts = User
        .where(role: "student")
        .where(created_at: Time.new(year).all_year)
        .group(group_by_month)
        .count
        .transform_keys(&:to_i)

      @chart_data[year] = (1..12).map { |m| counts[m] || 0 }
end
  end
end
