
FactoryBot.define do
  factory :user do
    full_name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    confirmed_at { Time.current }

    trait :student do
      role { "student" }
    end

    trait :admin do
      role { "admin" }
    end
    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
