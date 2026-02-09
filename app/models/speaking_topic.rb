class SpeakingTopic < ApplicationRecord
  belongs_to :lesson
  has_many :speaking_attempts
  has_many :speaking_questions, dependent: :destroy
  accepts_nested_attributes_for :speaking_questions, allow_destroy: true
  enum :part, {
    part1: "part1",
    part2: "part2",
    part3: "part3"
  }, suffix: true

end
