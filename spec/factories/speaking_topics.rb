FactoryBot.define do
  factory :speaking_topic do
    title { "Describe a book" }
    part { "part2" }
    association :lesson
  end
end
