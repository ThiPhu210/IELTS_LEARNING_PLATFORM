FactoryBot.define do
    factory :lesson do
      association :course_section
      title { "Sample Lesson" }
      duration { 45 } # phút
    end
  end
