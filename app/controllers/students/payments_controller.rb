# frozen_string_literal: true

class Students::PaymentsController < ApplicationController
  require "openssl"
  require "uri"
  require "cgi"
  require "net/http"
  require "json"
  require "securerandom"
  require "stripe"

  skip_before_action :authenticate_user!,
    only: [ :vnpay_return, :vnpay_ipn, :momo_notify, :momo_return, :stripe_webhook ],
    if: -> { respond_to?(:authenticate_user!) },
    raise: false

  skip_before_action :verify_authenticity_token,
    only: [ :vnpay_ipn, :momo_notify, :stripe_webhook ]

  # ================= VNPAY CONSTANTS =================
  VNP_URL         = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
  VNP_TMNCODE     = "9APTANC1"
  VNP_HASH_SECRET = "OV71K9S7ITDX3J2HF113O886GMZR72ZP"
  VNP_RETURN_URL  = "https://resigned-unincreased-agnus.ngrok-free.dev/students/payments/vnpay_return"

  # ================= MOMO CONSTANTS =================
  MOMO_ENDPOINT     = "https://test-payment.momo.vn/v2/gateway/api/create"
  MOMO_PARTNER_CODE = "MOMO"
  MOMO_ACCESS_KEY   = "F8BBA842ECF85"
  MOMO_SECRET_KEY   = "K951B6PE1waDMi640xX08PD3vg6EkVlz"
  MOMO_REDIRECT_URL = "https://resigned-unincreased-agnus.ngrok-free.dev/students/payments/momo_return"
  MOMO_IPN_URL      = "https://resigned-unincreased-agnus.ngrok-free.dev/students/payments/momo_notify"

  # ================= VNPAY CREATE =================
  def create
    order = current_user.orders.find(params[:order_id])

    payment = order.payments.create!(
      amount: order.total_price,
      payment_method: "vnpay",
      gateway_name: "vnpay",
      status: "pending"
    )

    txn_ref = "VNP#{payment.id}_#{SecureRandom.hex(4)}"
    payment.update!(gateway_order_id: txn_ref)

    vnp_params = {
      vnp_Version:   "2.1.0",
      vnp_Command:   "pay",
      vnp_TmnCode:   VNP_TMNCODE,
      vnp_Amount:    (order.total_price * 100).to_i,
      vnp_CurrCode:  "VND",
      vnp_TxnRef:    txn_ref,
      vnp_OrderInfo: "Order_#{order.id}",
      vnp_OrderType: "education",
      vnp_Locale:    "vn",
      vnp_ReturnUrl: VNP_RETURN_URL,
      vnp_IpAddr:    request.remote_ip,
      vnp_CreateDate: Time.current.strftime("%Y%m%d%H%M%S")
    }

    query_string = URI.encode_www_form(vnp_params.sort.to_h)
    secure_hash  = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET.to_s, query_string.to_s)

    redirect_to "#{VNP_URL}?#{query_string}&vnp_SecureHash=#{secure_hash}",
                allow_other_host: true
  end

  # ================= VNPAY RETURN =================
  def vnpay_return
    payment = Payment.find_by(gateway_order_id: params[:vnp_TxnRef])
    return redirect_to root_path unless payment

    if params[:vnp_ResponseCode] == "00"
      redirect_to students_dashboard_path, notice: "Bạn đã thanh toán thành công 🎉"
    else
      redirect_to students_course_path(payment.order.course),
                  alert: "Thanh toán thất bại"
    end
  end

  # ================= VNPAY IPN =================
  def vnpay_ipn
    vnp_params = params.to_unsafe_h.select { |k, _| k.start_with?("vnp_") && k != "vnp_SecureHash" }
    query      = vnp_params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    check_hash = OpenSSL::HMAC.hexdigest("SHA512", VNP_HASH_SECRET.to_s, query.to_s)

    return render json: { RspCode: "97" } if params[:vnp_SecureHash] != check_hash

    payment = Payment.find_by(gateway_order_id: params[:vnp_TxnRef])
    return render json: { RspCode: "01" } unless payment
    return render json: { RspCode: "00" } if payment.paid_status?

    if params[:vnp_ResponseCode] == "00"
      payment.update!(
        transaction_code: params[:vnp_TransactionNo],
        paid_at: Time.current,
        status: "paid"
      )

      CourseAccess.find_or_create_by!(
        user:   payment.order.user,
        course: payment.order.course
      ) do |ca|
        ca.payment    = payment
        ca.status     = :active
        ca.start_date = Time.current
        ca.end_date   = 1.year.from_now
      end

      payment.order.update!(status: :paid)
      Rails.logger.info "=== SEND INVOICE MAIL ==="
      InvoiceMailer.invoice_email(payment.order).deliver_later
    else
      payment.update!(status: "failed")
    end

    render json: { RspCode: "00" }
  end

  # ================= MOMO CREATE =================
  def momo_create
    order = current_user.orders.find(params[:order_id])

    payment = order.payments.create!(
      amount: order.total_price,
      payment_method: "momo",
      gateway_name: "momo",
      status: "pending"
    )

    order_id       = "ORD#{payment.id}_#{SecureRandom.hex(4)}"
    payment.update!(gateway_order_id: order_id)

    request_id     = SecureRandom.uuid
    amount         = order.total_price.to_i.to_s
    order_info     = "pay with MoMo"
    request_type   = "payWithMethod"
    extra_data     = ""
    order_group_id = ""
    auto_capture   = true
    lang           = "vi"

    raw_signature = [
      "accessKey=#{MOMO_ACCESS_KEY}",
      "amount=#{amount}",
      "extraData=#{extra_data}",
      "ipnUrl=#{MOMO_IPN_URL}",
      "orderId=#{order_id}",
      "orderInfo=#{order_info}",
      "partnerCode=#{MOMO_PARTNER_CODE}",
      "redirectUrl=#{MOMO_REDIRECT_URL}",
      "requestId=#{request_id}",
      "requestType=#{request_type}"
    ].join("&")

    signature = OpenSSL::HMAC.hexdigest("SHA256", MOMO_SECRET_KEY, raw_signature)

    body = {
      partnerCode:  MOMO_PARTNER_CODE,
      partnerName:  "MoMo Payment",
      storeId:      MOMO_PARTNER_CODE,
      requestId:    request_id,
      amount:       amount,
      orderId:      order_id,
      orderInfo:    order_info,
      redirectUrl:  MOMO_REDIRECT_URL,
      ipnUrl:       MOMO_IPN_URL,
      lang:         lang,
      autoCapture:  auto_capture,
      extraData:    extra_data,
      orderGroupId: order_group_id,
      requestType:  request_type,
      signature:    signature
    }

    Rails.logger.info "========== MOMO CREATE =========="
    Rails.logger.info "ORDER_ID: #{order_id}"
    Rails.logger.info "REQUEST_ID: #{request_id}"
    Rails.logger.info "AMOUNT: #{amount}"
    Rails.logger.info "RAW_SIGNATURE: #{raw_signature}"
    Rails.logger.info "SIGNATURE: #{signature}"

    uri  = URI.parse(MOMO_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.verify_mode  = OpenSSL::SSL::VERIFY_PEER

    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/json"
    req.body = body.to_json

    res  = http.request(req)
    json = JSON.parse(res.body)

    Rails.logger.info "========== MOMO RESPONSE =========="
    Rails.logger.info "HTTP STATUS: #{res.code}"
    Rails.logger.info "RESULT CODE: #{json["resultCode"]}"
    Rails.logger.info "MESSAGE: #{json["message"]}"
    Rails.logger.info "PAY URL: #{json["payUrl"]}"

    if json["resultCode"] == 0
      redirect_to json["payUrl"], allow_other_host: true
    else
      redirect_back fallback_location: root_path,
                    alert: "MoMo lỗi: #{json["message"]}"
    end
  end

  # ================= MOMO NOTIFY (IPN) =================
  def momo_notify
    raw_body = request.body.read
    Rails.logger.info "========== MOMO NOTIFY =========="
    Rails.logger.info "RAW BODY: #{raw_body}"

    json = JSON.parse(raw_body)

    payment = Payment.find_by(gateway_order_id: json["orderId"])
    return head :ok unless payment
    return head :ok if payment.paid_status?

    if json["resultCode"] == 0
      payment.update!(
        transaction_code: json["transId"].to_s,
        paid_at:          Time.current,
        status:           "paid"
      )

      CourseAccess.find_or_create_by!(
        user:   payment.order.user,
        course: payment.order.course
      ) do |ca|
        ca.payment    = payment
        ca.status     = :active
        ca.start_date = Time.current
        ca.end_date   = 1.year.from_now
      end

      payment.order.update!(status: :paid)
      InvoiceMailer.invoice_email(payment.order).deliver_later
    else
      payment.update!(status: "failed")
    end

    head :ok
  end

  # ================= MOMO RETURN =================
  def momo_return
    payment = Payment.find_by(gateway_order_id: params[:orderId])
    return redirect_to root_path unless payment

    if params[:resultCode] == "0"
      redirect_to students_dashboard_path,
                  notice: "Thanh toán MoMo thành công 🎉"
    else
      redirect_to students_course_path(payment.order.course),
                  alert: "Thanh toán thất bại (#{params[:message]})"
    end
  end

  # ================= STRIPE CREATE =================
  def stripe_create
    order = current_user.orders.find(params[:order_id])

    payment = order.payments.create!(
      amount: order.total_price,
      payment_method: "stripe",
      gateway_name: "stripe",
      status: "pending"
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      mode: "payment",
      line_items: [ {
        price_data: {
          currency: "vnd",
          product_data: { name: "Order #{order.id}" },
          unit_amount: order.total_price.to_i
        },
        quantity: 1
      } ],
      metadata: { payment_id: payment.id },
      success_url: stripe_success_students_payments_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  stripe_cancel_students_payments_url
    )

    payment.update!(gateway_order_id: session.id)
    redirect_to session.url, allow_other_host: true
  end

  # ================= STRIPE WEBHOOK =================
  def stripe_webhook
    payload        = request.body.read
    sig_header     = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

    if event["type"] == "checkout.session.completed"
      session = event["data"]["object"]
      payment = Payment.find_by(gateway_order_id: session.id)
      return head :ok unless payment
      return head :ok if payment.paid_status?

      payment.update!(
        status:           "paid",
        paid_at:          Time.current,
        transaction_code: session["payment_intent"]
      )

      CourseAccess.find_or_create_by!(
        user:   payment.order.user,
        course: payment.order.course
      ) do |ca|
        ca.payment    = payment
        ca.status     = :active
        ca.start_date = Time.current
        ca.end_date   = 1.year.from_now
      end

      payment.order.update!(status: :paid)
    end

    head :ok
  rescue Stripe::SignatureVerificationError
    head :bad_request
  rescue => e
    Rails.logger.error "Stripe webhook error: #{e.message}"
    head :ok
  end

  # ================= STRIPE SUCCESS =================
  def stripe_success
    session_id     = params[:session_id]
    stripe_session = Stripe::Checkout::Session.retrieve(session_id)
    payment        = Payment.find_by(gateway_order_id: stripe_session.id)

    if payment&.paid_status?
      redirect_to students_dashboard_path, notice: "Thanh toán Stripe thành công 🎉"
    else
      redirect_to students_dashboard_path, notice: "Đang xác nhận thanh toán..."
    end
  end

  # ================= STRIPE CANCEL =================
  def stripe_cancel
    redirect_to students_courses_path, alert: "Bạn đã hủy thanh toán Stripe"
  end
end
