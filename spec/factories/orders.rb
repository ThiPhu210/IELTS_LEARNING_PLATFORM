FactoryBot.define do
    factory :order do
      user
      course
      total_price { course.price }
      status { :pending }
    end
  end
