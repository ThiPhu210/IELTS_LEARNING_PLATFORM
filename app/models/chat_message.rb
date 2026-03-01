# app/models/chat_message.rb

class ChatMessage < ApplicationRecord
  DAILY_LIMIT = 10

  belongs_to :user
  belongs_to :course

  validates :role,    presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true
  validates :sent_on, presence: true

  before_validation :set_sent_on

  # Chỉ đếm tin nhắn của USER (không đếm assistant) để tính quota
  scope :user_messages_today, ->(user, course) {
    where(user: user, course: course, role: "user", sent_on: Date.today)
  }

  def self.daily_count_for(user, course)
    user_messages_today(user, course).count
  end

  def self.remaining_for(user, course)
    [DAILY_LIMIT - daily_count_for(user, course), 0].max
  end

  def self.can_chat?(user, course)
    daily_count_for(user, course) < DAILY_LIMIT
  end

  private

  def set_sent_on
    self.sent_on ||= Date.today
  end
end
