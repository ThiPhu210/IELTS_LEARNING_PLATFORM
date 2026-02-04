FactoryBot.define do
  factory :user do
    full_name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "student" } # ✅ default role
    school { "IELTS University" } 
    phone { "0901234567" } # ✅ default school cho student
    confirmed_at { Time.current }

    trait :student do
      role { "student" }
      school { "IELTS University" } # ✅ student bắt buộc school
    end

    trait :admin do
      role { "admin" }
      school { nil } # ✅ admin không cần school
    end


    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
