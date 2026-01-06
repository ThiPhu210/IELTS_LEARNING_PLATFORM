class Student::CoursesController < ApplicationController
    before_action :require_student
    def buy
      course = Course.find(params[:id])

      ActiveRecord::Base.transaction do
        course_access = CourseAccess.create!(
          user: current_user,
          course: course,
          status: :pending,
          start_date: Time.current,
          end_date: Time.current + course.duration_days.days
        )

        Payment.create!(
          course_access: course_access,
          amount: course.price,
          status: :pending,
          payment_method: "mock"
        )
      end

      redirect_to student_dashboard_path, notice: "🧾 Đã tạo đơn mua khóa học (mock payment)"
    end

    private

    def require_student
      redirect_to root_path unless current_user&.student?
    end
end
