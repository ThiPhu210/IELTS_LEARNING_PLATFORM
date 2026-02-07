FactoryBot.define do
  factory :payment do
    association :order
    amount { 999000 }
    payment_method { "vnpay" }
    transaction_code { SecureRandom.hex(8) }
    status { :paid }
  end
end
