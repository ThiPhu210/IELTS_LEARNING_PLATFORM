class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"
  require "cgi"

  skip_before_action :verify_authenticity_token, only: [:vnpay_ipn]
  before_action :authenticate_user!, except: [:vnpay_return, :vnpay_ipn]

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
      vnp_IpnUrl: "https://d34ute7tylgmox.cloudfront.net/students/payments/vnpay_ipn",
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
    Rails.logger.info "🔥 VNPAY IPN #{params.inspect}"

    vnp_params = params.to_unsafe_h.select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }
    secure_hash = params[:vnp_SecureHash]

    query = vnp_params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    check_hash = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET, query)

    if secure_hash != check_hash
      Rails.logger.error "❌ INVALID SIGNATURE"
      return render json: { RspCode: "97", Message: "Invalid Signature" }
    end

    order = Order.find_by(id: params[:vnp_TxnRef])
    return render(json: { RspCode: "01", Message: "Order Not Found" }) unless order

    # Check amount
    expected_amount = (order.total_price * 100).to_i
    if params[:vnp_Amount].to_i != expected_amount
      Rails.logger.error "❌ AMOUNT MISMATCH"
      return render json: { RspCode: "04", Message: "Invalid Amount" }
    end

    # Already paid
    if order.paid_status?
      return render json: { RspCode: "00", Message: "Already Processed" }
    end

    # Success
    if params[:vnp_ResponseCode] == "00" && params[:vnp_TransactionStatus] == "00"
      ActiveRecord::Base.transaction do
        order.update!(status: :paid)

        CourseAccess.find_or_create_by!(user: order.user, course: order.course) do |ca|
          ca.status = :active
          ca.start_date = Time.current
          ca.end_date = 1.year.from_now
        end
      end

      Rails.logger.info "✅ PAYMENT CONFIRMED ORDER #{order.id}"
      return render json: { RspCode: "00", Message: "Confirm Success" }
    end

    order.update!(status: :failed)
    render json: { RspCode: "02", Message: "Payment Failed" }
  end
end
