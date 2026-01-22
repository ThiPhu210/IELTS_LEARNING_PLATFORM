FactoryBot.define do
    factory :course_section do
      association :course
      title { "Introduction Section" }
      position { 1 }
    end
  end
