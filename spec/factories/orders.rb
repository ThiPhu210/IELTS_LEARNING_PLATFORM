FactoryBot.define do
  factory :order do
    user
    course
    total_price { 100 }
    status { :paid }
  end
end
