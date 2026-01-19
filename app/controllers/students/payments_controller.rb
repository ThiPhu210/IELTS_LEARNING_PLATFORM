class Students::PaymentsController < ApplicationController
  require "openssl"
  require "cgi"

  protect_from_forgery with: :exception
  before_action :authenticate_user!

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

    amount = order.total_price.to_i * 100 # VNPay dùng VND * 100

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
       params[:vnp_ResponseCode] == "00" &&
       params[:vnp_TransactionStatus] == "00"

      order = Order.find_by(id: params[:vnp_TxnRef])

      if order
        order.update!(status: :paid)

        Rails.logger.info "✅ VNPay SUCCESS – Order #{order.id}"
        Rails.logger.info "➡️ Status: #{order.status}"
        Rails.logger.info "➡️ User ID: #{order.user_id}"

        flash[:success] = "Thanh toán thành công 🎉"
      else
        flash[:error] = "Không tìm thấy đơn hàng"
      end

    else
      Rails.logger.info "❌ VNPay FAILED"
      flash[:error] = "Thanh toán thất bại ❌"
    end

    redirect_to students_dashboard_path
  end
end
