FactoryBot.define do
  factory :speaking_topic do
    title { "Sample Speaking Topic" }
    part  { "part2" }

    association :lesson
  end
end
