class Students::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_order, only: [:checkout, :pay]

  # ======================
  # GET /students/courses/:course_id/orders/new
  # ======================
  def new
    @order = current_user.orders.build(
      course: @course,
      total_price: @course.price,
      status: :pending
    )
  end

  # ======================
  # POST /students/courses/:course_id/orders
  # ======================
  def create
    @order = Order.create!(
      user: current_user,
      course: @course,
      status: :paid,
      total_price: @course.price
    )
    

    flash[:success] = "Đơn hàng đã được tạo thành công, bạn chờ tí nha!"
    redirect_to checkout_students_course_order_path(@course, @order)
  end

  # ======================
  # GET /students/courses/:course_id/orders/:id/checkout
  # ======================
  def checkout
    # @order đã được set & check user ở before_action
  end

  # ======================
  # POST /students/courses/:course_id/orders/:id/pay
  # ======================
  def pay
    # ====== VNPay config (sandbox) ======
    vnp_tmn_code    = "9APTANC1"
    vnp_hash_secret = "OV71K9S7ITDX3J2HF113O886GMZR72ZP"
    vnp_url         = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
    return_url = Rails.application.routes.url_helpers
                .students_payments_vnpay_return_url(
                  host: request.base_url
                )


    order = Order.find(params[:id])

    # ====== Params gửi sang VNPay ======
  vnp_params = {
    vnp_Version: "2.1.0",
    vnp_Command: "pay",
    vnp_TmnCode: "9APTANC1",
    vnp_Amount: (order.total_price * 100).to_i,
    vnp_CurrCode: "VND",
    vnp_TxnRef: order.id.to_s,
    vnp_OrderInfo: "Thanh toan don hang #{order.id}",
    vnp_OrderType: "other",
    vnp_Locale: "vn",
    vnp_ReturnUrl: students_vnpay_return_url(host: request.base_url),
    vnp_IpAddr: request.remote_ip,
    vnp_CreateDate: Time.now.strftime("%Y%m%d%H%M%S")
  }.compact


    # ====== Sort params ======
    sorted_params = vnp_params.sort.to_h

    # ====== Tạo query string ======
    query_string = sorted_params
                     .map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }
                     .join("&")

    # ====== Secure hash ======
    secure_hash = OpenSSL::HMAC.hexdigest(
      "SHA512",
      "OV71K9S7ITDX3J2HF113O886GMZR72ZP",
      query_string
    )

    payment_url = "#{vnp_url}?#{query_string}&vnp_SecureHash=#{secure_hash}"

    # ====== Redirect sang VNPay ======
    redirect_to payment_url, allow_other_host: true
  end

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
  def order_params
    params.require(:order).permit(:course_id, :status)
  end
  
end
