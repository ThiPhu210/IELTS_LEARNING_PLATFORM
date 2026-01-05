FactoryBot.define do
    factory :user do
      full_name { "Test User" }
      sequence(:email) { |n| "user#{n}@example.com" }
      password { "password" }
      role { :student } # admin, teacher, student
    end
  end
  