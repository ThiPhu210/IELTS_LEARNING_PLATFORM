require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:course_access) }
  end
  subject do build(:payment)
  end
  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:payment_method) }
    it { should validate_presence_of(:transaction_code) }
    it { should validate_uniqueness_of(:transaction_code) }
  end

  describe "scopes" do
    it "returns only paid payments" do
      paid = create(:payment, status: :paid, amount: 100, payment_method: "card", transaction_code: "TX123")
      pending = create(:payment, status: :pending, amount: 200, payment_method: "paypal", transaction_code: "TX124")

      expect(Payment.paid_payments).to include(paid)
      expect(Payment.paid_payments).not_to include(pending)
    end
  end
end
