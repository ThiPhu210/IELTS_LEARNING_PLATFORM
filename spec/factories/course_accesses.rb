FactoryBot.define do
  factory :course_access do
    association :user
    association :course
    association :payment
    status { :active }
    start_date { Time.current }
    end_date { 1.year.from_now }
  end
end
