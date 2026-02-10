FactoryBot.define do
  factory :section do
    title { "Section 1" }
    association :course
  end
end
