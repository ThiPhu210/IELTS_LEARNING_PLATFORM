FactoryBot.define do
  factory :course_access do
    association :user
    association :course
    association :order
    start_date { Time.current }
    end_date { 30.days.from_now }
    status { :active }
  end
end
