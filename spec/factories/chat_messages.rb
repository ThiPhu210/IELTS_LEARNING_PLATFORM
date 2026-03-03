FactoryBot.define do
  factory :chat_message do
    association :user
    association :course
    role { "user" }
    content { "Test message" }
    sent_on { Date.today }
  end
end
