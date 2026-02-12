class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        ENV["STRIPE_WEBHOOK_SECRET"]
      )

      case event.type

      when "checkout.session.completed"
        session = event.data.object
        payment = Payment.find(session.metadata.payment_id)

        unless payment.paid_status?
          payment.update!(
            transaction_code: session.payment_intent,
            paid_at: Time.current,
            status: "paid"
          )

          CourseAccess.create!(
            user: payment.order.user,
            course: payment.order.course,
            payment: payment,
            status: :active,
            start_date: Time.current,
            end_date: 1.year.from_now
          )

          payment.order.update!(status: :paid)
        end
      end

      render json: { message: "success" }
    rescue JSON::ParserError
      head :bad_request
    rescue Stripe::SignatureVerificationError
      head :unauthorized
    end
end
