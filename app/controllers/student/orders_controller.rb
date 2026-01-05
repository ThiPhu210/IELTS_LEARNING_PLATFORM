class Student::OrdersController < ApplicationController
    before_action :require_login
  
    # 1️⃣ Tạo order và chuyển tới checkout
    def create
      course = Course.find(params[:course_id])
  
      # Kiểm tra nếu đã mua rồi, redirect về dashboard
      if CourseAccess.exists?(user: current_user, course: course, status: :active)
        redirect_to student_dashboard_path, notice: "Bạn đã mua khóa học này."
        return
      end
  
      # Tạo CourseAccess + Order + Payment nhưng vẫn pending
      course_access = CourseAccess.create!(
        user: current_user,
        course: course,
        start_date: Time.current,
        end_date: Time.current + course.duration_days.days,
        status: :pending
      )
  
      order = Order.create!(
        user: current_user,
        course: course,
        total_price: course.price,
        status: :pending
      )
  
      payment = Payment.create!(
        order: order,
        course_access: course_access,
        amount: course.price,
        payment_method: nil,
        transaction_code: nil,
        status: :pending
      )
  
      # Chuyển đến trang checkout
      redirect_to checkout_student_orders_path(course_access_id: course_access.id)
    end
  
    # 2️⃣ Trang checkout
    def checkout
      @course_access = CourseAccess.find(params[:course_access_id])
    end
  
    # 3️⃣ Xử lý thanh toán (mock)
    def pay
      @course_access = CourseAccess.find(params[:course_access_id])
      payment = @course_access.payments.first
  
      # Mock thanh toán thành công
      payment.update!(
        status: :paid,
        payment_method: "mock",
        transaction_code: SecureRandom.hex(10)
      )
  
      @course_access.update!(status: :active)
  
      redirect_to student_dashboard_path, notice: "🎉 Thanh toán thành công! Khóa học đã được mở."
    end
  end
  