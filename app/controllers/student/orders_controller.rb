class Student::OrdersController < ApplicationController
  # before_action :require_login

  def create
    # course = Course.find(params[:course_id])

    # course_access = CourseAccess.find_by(
    #   user: current_user,
    #   course: course
    # )

    # # 1️⃣ Nếu đã mua & còn hạn → không cho mua lại
    # if course_access&.active?
    #   && course_access.end_date > Time.current
    #   redirect_to student_dashboard_path, notice: "Bạn đã mua khóa học này."
    #   return
    # end

    # # 2️⃣ Nếu đã tồn tại (pending / expired) → dùng lại
    # if course_access
    #   course_access.update!(
    #     start_date: Time.current,
    #     end_date: Time.current + course.duration_days.days,
    #     status: :pending
    #   )
    # else
    #   # 3️⃣ Chưa từng mua → tạo mới
    #   course_access = CourseAccess.create!(
    #     user: current_user,
    #     course: course,
    #     start_date: Time.current,
    #     end_date: Time.current + course.duration_days.days,
    #     status: :pending
    #   )
    # end

    # # 4️⃣ Luôn tạo Order mới
    # order = Order.create!(
    #   user: current_user,
    #   course: course,
    #   total_price: course.price,
    #   status: :pending
    # )

    # # 5️⃣ Payment mock
    # Payment.create!(
    #   order: order,
    #   course_access: course_access,
    #   amount: course.price,
    #   payment_method: "mock",
    #   transaction_code: SecureRandom.hex(10),
    #   status: :pending
    # )

    # redirect_to checkout_student_orders_path(course_access_id: course_access.id)
  end

  def checkout
    # @course_access = CourseAccess.find(params[:course_access_id])
  end

  def pay
    # course_access = CourseAccess.find(params[:course_access_id])
    # payment = course_access.payments.last

    # payment.update!(status: :paid)
    # course_access.update!(status: :active)

    # redirect_to student_dashboard_path,
    #             notice: "🎉 Thanh toán thành công! Khóa học đã được mở."
  end
end
