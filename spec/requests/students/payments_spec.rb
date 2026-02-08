require "rails_helper"
require "openssl"
require "cgi"

RSpec.describe "Students::PaymentsController", type: :request do
  let(:user)   { create(:user) }
  let(:course) { create(:course) }

  let(:order) do
    create(:order,
      user: user,
      course: course,
      total_price: 999000,
      status: :pending
    )
  end

  before do
    sign_in user, scope: :user
  end

  # ================= CREATE PAYMENT =================
  describe "POST /students/payments" do
    it "redirects to VNPay with gateway_order_id" do
      post students_payments_path, params: { order_id: order.id }

      payment = Payment.last

      expect(response).to have_http_status(:redirect)
      expect(response.location).to include(payment.gateway_order_id)
    end
  end

  # ================= RETURN =================
  describe "GET /vnpay_return" do
    let!(:payment) do
      create(:payment,
        order: order,
        gateway_order_id: "VNP_TEST",
        status: :pending
      )
    end

    it "redirect success when response code 00" do
      get vnpay_return_students_payments_path,
          params: { vnp_TxnRef: payment.gateway_order_id, vnp_ResponseCode: "00" }

      expect(response).to redirect_to(students_dashboard_path)
    end

    it "redirect fail when response code not 00" do
      get vnpay_return_students_payments_path,
          params: { vnp_TxnRef: payment.gateway_order_id, vnp_ResponseCode: "24" }

      expect(response).to redirect_to(students_course_path(course))
    end
  end

  # ================= IPN =================
  describe "GET /vnpay_ipn" do
    let!(:payment) do
      create(:payment,
        order: order,
        gateway_order_id: "VNP_TEST",
        status: :pending
      )
    end

    def generate_signature(params)
      data = params.sort.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      OpenSSL::HMAC.hexdigest(
        "SHA512",
        Students::PaymentsController::VNP_HASH_SECRET,
        data
      )
    end

    it "marks payment paid + create course access" do
      vnp_params = {
        vnp_TxnRef: payment.gateway_order_id,
        vnp_Amount: "99900000",
        vnp_ResponseCode: "00",
        vnp_TransactionNo: "123456"
      }

      signature = generate_signature(vnp_params)

      expect {
        get vnpay_ipn_students_payments_path,
            params: vnp_params.merge(vnp_SecureHash: signature)
      }.to change(CourseAccess, :count).by(1)

      payment.reload
      order.reload

      expect(payment.status).to eq("paid")
      expect(order.status).to eq("paid")
    end

    it "rejects invalid signature" do
      get vnpay_ipn_students_payments_path,
          params: {
            vnp_TxnRef: payment.gateway_order_id,
            vnp_SecureHash: "fake"
          }

      body = JSON.parse(response.body)
      expect(body["RspCode"]).to eq("97")
    end

    it "does not duplicate course access on replay IPN" do
      vnp_params = {
        vnp_TxnRef: payment.gateway_order_id,
        vnp_Amount: "99900000",
        vnp_ResponseCode: "00",
        vnp_TransactionNo: "123456"
      }

      signature = generate_signature(vnp_params)

      2.times do
        get vnpay_ipn_students_payments_path,
            params: vnp_params.merge(vnp_SecureHash: signature)
      end

      expect(CourseAccess.count).to eq(1)
    end

    it "handles failed payment" do
      vnp_params = {
        vnp_TxnRef: payment.gateway_order_id,
        vnp_Amount: "99900000",
        vnp_ResponseCode: "24",
        vnp_TransactionNo: "999999"
      }

      signature = generate_signature(vnp_params)

      get vnpay_ipn_students_payments_path,
          params: vnp_params.merge(vnp_SecureHash: signature)

      payment.reload
      expect(payment.status).to eq("failed")
    end
  end
end
