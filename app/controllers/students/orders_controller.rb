class Students::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_order, only: [:checkout]

  # ======================
  # GET /students/courses/:course_id/orders/new
  # ======================
 def new
    @order = current_user.orders.build(course: @course)
  end

  # ======================
  # POST /students/courses/:course_id/orders
  # ======================
  def create
    if current_user.course_accesses.active_status.exists?(course: @course)
      return redirect_to students_course_path(@course), alert: "Bạn đã sở hữu khóa học này"
    end

    @order = current_user.orders.create!(
      course: @course,
      total_price: @course.price,
      status: :pending
    )

    redirect_to checkout_students_course_order_path(@course, @order)
  end

  # ======================
  # GET /students/courses/:course_id/orders/:id/checkout
  # ======================
  def checkout
  end

  # ======================
  
  private

  # ======================
  # Load course
  # ======================
  def set_course
    @course = Course.find(params[:course_id])
  end

  # ======================
  # Load order + lock theo user
  # ======================
  def set_order
    @order = current_user.orders.find(params[:id])
  end

end
