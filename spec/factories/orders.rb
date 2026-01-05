FactoryBot.define do
  factory :order do
    user { nil }
    course { nil }
    total_price { "9.99" }
    status { 1 }
  end
end
