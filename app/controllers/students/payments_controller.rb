class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"

  skip_before_action :verify_authenticity_token, only: [:vnpay_ipn]
  before_action :authenticate_user!, except: [:vnpay_return, :vnpay_ipn]

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
      "vnp_TxnRef"     => order.id.to_s,
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
    order = Order.find_by(id: params[:vnp_TxnRef])
    return redirect_to root_path, alert: "Order not found" unless order

    if params[:vnp_ResponseCode] == "00"
      ActiveRecord::Base.transaction do
        order.update!(status: :paid)

        payment = order.create_payment!(
          amount: order.total_price,
          status: :paid,
          transaction_code: params[:vnp_TransactionNo]
        )

        CourseAccess.create!(
          user: order.user,
          course: order.course,
          payment: payment,
          start_date: Time.current,
          end_date: 1.year.from_now,
          status: :active
        )
      end

      redirect_to students_course_path(order.course), notice: "Thanh toán thành công"
    else
      order.update!(status: :failed)
      redirect_to students_course_path(order.course), alert: "Thanh toán thất bại"
    end
  end

  # ================== IPN (SERVER TO SERVER) ==================
  def vnpay_ipn
    Rails.logger.info "🔥 VNPAY IPN #{params.inspect}"

    vnp_params = params.to_unsafe_h.select { |k, _| k.start_with?("vnp_") }
    secure_hash = vnp_params.delete("vnp_SecureHash")
    vnp_params.delete("vnp_SecureHashType")

    sorted = vnp_params.sort.to_h
    hash_data = URI.encode_www_form(sorted)
    check_hash = OpenSSL::HMAC.hexdigest("SHA512", VN_PAY[:hash_secret], hash_data)

    Rails.logger.info "VNPay IPN HASH DATA: #{hash_data}"
    Rails.logger.info "VNPay IPN HASH CHECK: #{check_hash}"

    return render json: { RspCode: "97", Message: "Invalid Signature" } if secure_hash != check_hash

    order = Order.find_by(id: params[:vnp_TxnRef])
    return render json: { RspCode: "01", Message: "Order Not Found" } unless order

    expected_amount = (order.total_price * 100).to_i
    return render json: { RspCode: "04", Message: "Invalid Amount" } if params[:vnp_Amount].to_i != expected_amount

    if params[:vnp_ResponseCode] == "00" && params[:vnp_TransactionStatus] == "00"
      return render json: { RspCode: "00", Message: "Already Processed" } if order.paid_status?

      ActiveRecord::Base.transaction do
        order.update!(status: :paid)

        payment = order.create_payment!(
          amount: order.total_price,
          status: :paid,
          transaction_code: params[:vnp_TransactionNo]
        )

        CourseAccess.create!(
          user: order.user,
          course: order.course,
          payment: payment,
          start_date: Time.current,
          end_date: 1.year.from_now,
          status: :active
        )
      end

      InvoiceMailer.invoice_email(order).deliver_later rescue nil

      return render json: { RspCode: "00", Message: "Confirm Success" }
    end

    render json: { RspCode: "02", Message: "Payment Failed" }
  end
end
