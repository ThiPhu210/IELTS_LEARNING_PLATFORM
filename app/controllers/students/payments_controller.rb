class Students::PaymentsController < ApplicationController
  require "openssl"
  require "cgi"
  skip_before_action :verify_authenticity_token, only: :vnpay_ipn
  protect_from_forgery with: :exception
  before_action :authenticate_user!, only: :vnpay_ipn

  # ================== CREATE PAYMENT ==================
  def create
    return unless params[:payment_method] == "vnpay"

    order = Order.find_by(id: params[:order_id])

    unless order
      flash[:error] = "Không tìm thấy đơn hàng"
      return redirect_back fallback_location: students_dashboard_path
    end

    # ✅ đảm bảo order thuộc user hiện tại
    unless order.user_id == current_user.id
      flash[:error] = "Đơn hàng không hợp lệ"
      return redirect_to students_dashboard_path
    end

    amount = order.total_price.to_i * 100

    vnp_params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: VN_PAY[:tmn_code],
      vnp_Amount: amount,
      vnp_CurrCode: "VND",
      vnp_TxnRef: order.id, # 🔥 ID ORDER
      vnp_OrderInfo: "Thanh toán khóa học #{order.course.title}",
      vnp_OrderType: "education",
      vnp_Locale: "vn",
      vnp_ReturnUrl: VN_PAY[:return_url],
      vnp_IpAddr: request.remote_ip,
      vnp_CreateDate: Time.current.strftime("%Y%m%d%H%M%S")
    }

    query = vnp_params
              .sort
              .map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }
              .join("&")

    secure_hash = OpenSSL::HMAC.hexdigest(
      "SHA512",
      VN_PAY[:hash_secret],
      query
    )

    redirect_to "#{VN_PAY[:url]}?#{query}&vnp_SecureHash=#{secure_hash}",
                allow_other_host: true
  end
def vnpay_ipn
  Rails.logger.info "🔥🔥 VNPAY IPN 🔥🔥"

  vnp_params = params
    .to_unsafe_h
    .select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }

  secure_hash = params[:vnp_SecureHash]

  query = vnp_params
            .sort
            .map { |k, v| "#{k}=#{v}" }
            .join("&")

  check_hash = OpenSSL::HMAC.hexdigest(
    "SHA512",
    VN_PAY[:hash_secret],
    query
  )

  unless secure_hash == check_hash
    return render json: { RspCode: "97", Message: "Invalid Signature" }
  end

  order = Order.find_by(id: params[:vnp_TxnRef])

  unless order
    return render json: { RspCode: "01", Message: "Order Not Found" }
  end

  if params[:vnp_ResponseCode] == "00" &&
     params[:vnp_TransactionStatus] == "00"

    order.update!(
      status: :paid,
      paid_at: Time.current
    )

    Rails.logger.info "✅ IPN CONFIRMED – Order #{order.id}"
    InvoiceMailer.invoice_email(order).deliver_later
    render json: { RspCode: "00", Message: "Confirm Success" }
  else
    render json: { RspCode: "02", Message: "Payment Failed" }
  end
end
  # ================== VNPAY RETURN ==================
  def vnpay_return
  Rails.logger.info "🔥🔥 VNPAY RETURN 🔥🔥"

  vnp_params = params
    .to_unsafe_h
    .select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }

  secure_hash = params[:vnp_SecureHash]

  query = vnp_params
            .sort
            .map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }
            .join("&")

  check_hash = OpenSSL::HMAC.hexdigest(
    "SHA512",
    VN_PAY[:hash_secret],
    query
  )

  if secure_hash == check_hash &&
     params[:vnp_ResponseCode] == "00"
    flash[:success] = "Thanh toán thành công 🎉 (đang xử lý)"
  else
    flash[:error] = "Thanh toán thất bại ❌"
  end

  redirect_to students_dashboard_path
end
end
