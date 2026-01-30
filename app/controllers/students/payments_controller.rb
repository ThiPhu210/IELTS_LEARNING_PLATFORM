# frozen_string_literal: true

class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"
  require "cgi"

  # ❗ IPN + RETURN không cần login + không CSRF
  skip_before_action :authenticate_user!, only: [:vnpay_return, :vnpay_ipn]
  skip_before_action :verify_authenticity_token, only: [:vnpay_ipn]

  VNP_URL         = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
  VNP_TMNCODE     = "9APTANC1"
  VNP_HASH_SECRET = "OV71K9S7ITDX3J2HF113O886GMZR72ZP"
  VNP_RETURN_URL  = "https://resigned-unincreased-agnus.ngrok-free.dev/students/payments/vnpay_return"

  # ================= CREATE PAYMENT =================
  def create
    order = current_user.orders.find(params[:order_id])

    vnp_params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: VNP_TMNCODE,
      vnp_Amount: (order.total_price * 100).to_i,
      vnp_CurrCode: "VND",
      vnp_TxnRef: order.id.to_s,
      vnp_OrderInfo: "Order_#{order.id}",
      vnp_OrderType: "education",
      vnp_Locale: "vn",
      vnp_ReturnUrl: VNP_RETURN_URL,
      vnp_IpAddr: request.headers["X-Forwarded-For"] || request.remote_ip,
      vnp_CreateDate: Time.current.strftime("%Y%m%d%H%M%S")
    }

    sorted = vnp_params.sort.to_h
    query_string = URI.encode_www_form(sorted)
    secure_hash  = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET, query_string)

    Rails.logger.info "VNPay HASH DATA: #{query_string}"
    Rails.logger.info "VNPay HASH: #{secure_hash}"

    redirect_to "#{VNP_URL}?#{query_string}&vnp_SecureHash=#{secure_hash}", allow_other_host: true
  end

  # ================= RETURN URL (UI ONLY) =================
  def vnpay_return
    order = Order.find_by(id: params[:vnp_TxnRef])
    return redirect_to root_path unless order

    if params[:vnp_ResponseCode] == "00"
      redirect_to students_course_path(order.course), notice: "Thanh toán thành công. Đang xác nhận..."
    else
      redirect_to students_course_path(order.course), alert: "Thanh toán thất bại"
    end
  end


  
  # ================= IPN (REAL CONFIRMATION) =================
 def vnpay_ipn
  Rails.logger.info "🔥 VNPAY IPN CALLED"
  vnp_params = params.to_unsafe_h.select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }
  secure_hash = params[:vnp_SecureHash]

  query = vnp_params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
  check_hash = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET, query)
  return render json: { RspCode: "97", Message: "Invalid Signature" } if secure_hash != check_hash

  order = Order.find_by(id: params[:vnp_TxnRef])
  return render json: { RspCode: "01", Message: "Order Not Found" } unless order

  if order.payment&.status == "success"
    return render json: { RspCode: "00", Message: "Already Processed" }
  end

  if params[:vnp_ResponseCode] == "00" && params[:vnp_TransactionStatus] == "00"
    ActiveRecord::Base.transaction do
      # 1️⃣ Create Payment
      payment = Payment.create!(
        order: order,
        amount: params[:vnp_Amount].to_i / 100,
        payment_method: "vnpay",
        transaction_code: params[:vnp_TransactionNo],
        paid_at: Time.current,
        status: "paid"
      )

      # 2️⃣ Create CourseAccess
      CourseAccess.create!(
        user: order.user,
        course: order.course,
        payment: payment,
        status: :active,
        start_date: Time.current,
        end_date: 1.year.from_now
      )

      order.update!(status: :paid)
    end

    return render json: { RspCode: "00", Message: "Confirm Success" }
  end

  Payment.create!(
    order: order,
    amount: params[:vnp_Amount].to_i / 100,
    payment_method: "vnpay",
    transaction_code: params[:vnp_TransactionNo],
    status: "failed"
  )

  render json: { RspCode: "02", Message: "Payment Failed" }
end

end
