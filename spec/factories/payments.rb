FactoryBot.define do
  factory :payment do
    order
    amount { 100 }
    payment_method { "card" }
    transaction_code { SecureRandom.hex(8) }
    status { :paid }
  end
end
