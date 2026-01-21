# host = "d34ute7tylgmox.cloudfront.net"

# Rails.application.routes.default_url_options[:host] = host
# Rails.application.routes.default_url_options[:protocol] = "https"

# ActionMailer::Base.default_url_options = {
#   host: host,
#   protocol: "https"
# }
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
