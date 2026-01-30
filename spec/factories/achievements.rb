FactoryBot.define do
  factory :achievement do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    year { 1 }
    ielts_overall_band { "9.99" }
  end
end
