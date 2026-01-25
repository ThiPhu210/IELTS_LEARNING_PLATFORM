FactoryBot.define do
    factory :payment do
      association :order
      association :course_access
      amount { 100.0 }
      payment_method { "credit_card" }
      sequence(:transaction_code) { |n| "TX#{n}" }
      status { :paid }
    end
  end
