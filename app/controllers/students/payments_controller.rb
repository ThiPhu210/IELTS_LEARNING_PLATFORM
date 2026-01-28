class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"

  skip_before_action :verify_authenticity_token, only: [ :vnpay_ipn ]
  before_action :authenticate_user!, except: [ :vnpay_return, :vnpay_ipn ]

  # ================== CREATE PAYMENT ==================
  def create
    order = current_user.orders.find(params[:order_id])

    order_info = "Order_#{order.id}"

    vnp_params = {
      "vnp_Version"    => "2.1.0",
      "vnp_Command"    => "pay",
      "vnp_TmnCode"    => VN_PAY[:tmn_code],
      "vnp_Amount"     => (order.total_price * 100).to_i,
      "vnp_CurrCode"   => "VND",
      "vnp_TxnRef"     => "#{order.id}_#{Time.current.to_i}",
      "vnp_OrderInfo"  => order_info,
      "vnp_OrderType"  => "education",
      "vnp_Locale"     => "vn",
      "vnp_ReturnUrl"  => VN_PAY[:return_url],
      "vnp_IpAddr"     => request.headers["X-Forwarded-For"] || request.remote_ip,
      "vnp_CreateDate" => Time.current.strftime("%Y%m%d%H%M%S")
    }

    sorted = vnp_params.sort.to_h
    query_string = URI.encode_www_form(sorted)
    secure_hash = OpenSSL::HMAC.hexdigest("SHA512", VN_PAY[:hash_secret], query_string)

    Rails.logger.info "VNPay HASH DATA: #{query_string}"
    Rails.logger.info "VNPay HASH: #{secure_hash}"

    redirect_to "#{VN_PAY[:url]}?#{query_string}&vnp_SecureHash=#{secure_hash}", allow_other_host: true
  end

  # ================== RETURN URL ==================
  def vnpay_return
    txn_ref = params[:vnp_TxnRef]
    order_id = txn_ref.split("_").first
    order = Order.find_by(id: order_id)
    return redirect_to root_path unless order

    if params[:vnp_ResponseCode] == "00"
      redirect_to students_course_path(order.course), notice: "Đã nhận yêu cầu thanh toán, đang xác nhận..."
    else
      redirect_to students_course_path(order.course), alert: "Thanh toán thất bại"
    end
  end


  # ================== IPN (SERVER TO SERVER) ==================
  def vnpay_ipn
  Rails.logger.info "🔥 VNPAY IPN #{params.inspect}"

  vnp_params = params.to_unsafe_h
                    .select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }

  secure_hash = params[:vnp_SecureHash]

  query = vnp_params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")

  check_hash = OpenSSL::HMAC.hexdigest("SHA512", ENV["VNP_HASH_SECRET"], query)

  return render(json: { RspCode: "97", Message: "Invalid Signature" }) if secure_hash != check_hash

  order = Order.find_by(id: params[:vnp_TxnRef])
  return render(json: { RspCode: "01", Message: "Order Not Found" }) unless order

  # Check amount
  expected_amount = order.total_price * 100
  if params[:vnp_Amount].to_i != expected_amount
    return render json: { RspCode: "04", Message: "Invalid Amount" }
  end

  # Success
  if params[:vnp_ResponseCode] == "00" && params[:vnp_TransactionStatus] == "00"

    # Idempotent check
    return render(json: { RspCode: "00", Message: "Already Processed" }) if order.paid_status?

    ActiveRecord::Base.transaction do
      order.update!(status: :paid)

      CourseAccess.find_or_create_by!(user: order.user, course: order.course) do |ca|
        ca.start_date = Time.current
        ca.end_date   = 1.year.from_now
        ca.status     = :active
      end
    end

    InvoiceMailer.invoice_email(order).deliver_later

    return render json: { RspCode: "00", Message: "Confirm Success" }
  end

  render json: { RspCode: "02", Message: "Payment Failed" }
end

end
