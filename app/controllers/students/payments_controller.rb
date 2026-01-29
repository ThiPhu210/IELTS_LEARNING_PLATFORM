class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"
  require "cgi"
  skip_before_action :authenticate_user!, only: [:vnpay_return, :vnpay_ipn]
  skip_before_action :verify_authenticity_token, only: [:vnpay_ipn]
  VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
  VNP_TMNCODE = "9APTANC1"
  VNP_HASH_SECRET = "OV71K9S7ITDX3J2HF113O886GMZR72ZP"
  VNP_RETURN_URL = "https://d34ute7tylgmox.cloudfront.net/students/payments/vnpay_return"

  # ================= CREATE PAYMENT =================
  def create
    order = current_user.orders.find(params[:order_id])

    vnp_params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: VNP_TMNCODE,
      vnp_Amount: (order.total_price * 100).to_i,
      vnp_CurrCode: "VND",
      vnp_TxnRef: order.id.to_s, # ❗ KHÔNG thêm timestamp
      vnp_OrderInfo: "Order_#{order.id}",
      vnp_OrderType: "education",
      vnp_Locale: "vn",
      vnp_ReturnUrl: VNP_RETURN_URL,
      vnp_IpAddr: request.headers["X-Forwarded-For"] || request.remote_ip,
      vnp_CreateDate: Time.current.strftime("%Y%m%d%H%M%S")
    }

    sorted = vnp_params.sort.to_h
    query_string = URI.encode_www_form(sorted)
    secure_hash = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET, query_string)

    Rails.logger.info "VNPay HASH DATA: #{query_string}"
    Rails.logger.info "VNPay HASH: #{secure_hash}"

    redirect_to "#{VNP_URL}?#{query_string}&vnp_SecureHash=#{secure_hash}", allow_other_host: true
  end

  # ================= RETURN URL (UI ONLY) =================
  def vnpay_return
    order = Order.find_by(id: params[:vnp_TxnRef])
    return redirect_to root_path unless order

    if params[:vnp_ResponseCode] == "00"
      redirect_to students_course_path(order.course), notice: "Đang xác nhận thanh toán..."
    else
      redirect_to students_course_path(order.course), alert: "Thanh toán thất bại"
    end
  end

  # ================= IPN (REAL PAYMENT CONFIRM) =================
 def vnpay_ipn
  Rails.logger.info "🔥🔥🔥 VNPAY IPN CALLED"
  Rails.logger.info params.inspect

  # TEST MODE: luôn trả thành công
  render json: { RspCode: "00", Message: "Confirm Success" }
end

end
