class Student::PaymentsController < ApplicationController
    def mark_paid
      payment = Payment.find(params[:id])
  
      ActiveRecord::Base.transaction do
        payment.update!(status: :paid, paid_at: Time.current)
        payment.course_access.update!(status: :active)
      end
  
      redirect_to student_dashboard_path, notice: "✅ Thanh toán thành công!"
    end
  end
  