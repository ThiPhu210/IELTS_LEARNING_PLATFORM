FactoryBot.define do
  factory :course_access do
    user
    course
    payment
    start_date { Time.current }
    end_date { 30.days.from_now }
    status { :active }
  end
end
