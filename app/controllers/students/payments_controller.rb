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
  VNP_RETURN_URL  = "http://184.72.213.33:3000/students/payments/vnpay_return"

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
    Rails.logger.info "🔥🔥🔥 VNPAY IPN CALLED"
    Rails.logger.info params.inspect

    # 1️⃣ Lấy params VNPay
    vnp_params = params.to_unsafe_h.select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }
    secure_hash = params[:vnp_SecureHash]

    # 2️⃣ Build query hash
    query = vnp_params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    check_hash = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET, query)

    # 3️⃣ Verify signature
    if secure_hash != check_hash
      Rails.logger.error "❌ INVALID SIGNATURE"
      return render json: { RspCode: "97", Message: "Invalid Signature" }
    end

    # 4️⃣ Find order
    order = Order.find_by(id: params[:vnp_TxnRef])
    return render json: { RspCode: "01", Message: "Order Not Found" } unless order

    # 5️⃣ Check amount
    expected_amount = (order.total_price * 100).to_i
    if params[:vnp_Amount].to_i != expected_amount
      Rails.logger.error "❌ AMOUNT MISMATCH"
      return render json: { RspCode: "04", Message: "Invalid Amount" }
    end

    # 6️⃣ Idempotent (VNPay gọi nhiều lần)
    if order.paid?
      return render json: { RspCode: "00", Message: "Already Processed" }
    end

    # 7️⃣ Payment success
    if params[:vnp_ResponseCode] == "00" && params[:vnp_TransactionStatus] == "00"
      ActiveRecord::Base.transaction do
        order.update!(status: :paid, paid_at: Time.current)

        CourseAccess.find_or_create_by!(user: order.user, course: order.course) do |ca|
          ca.status = :active
          ca.start_date = Time.current
          ca.end_date   = 1.year.from_now
        end
      end

      Rails.logger.info "✅ PAYMENT CONFIRMED ORDER #{order.id}"
      return render json: { RspCode: "00", Message: "Confirm Success" }
    end

    # 8️⃣ Failed payment
    order.update!(status: :failed)
    render json: { RspCode: "02", Message: "Payment Failed" }
  end
end
