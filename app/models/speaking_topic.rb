class SpeakingTopic < ApplicationRecord
  belongs_to :course
  has_many :speaking_questions, dependent: :destroy
  has_many :speaking_attempts

  # enum part: {
  #   part1: "part1",
  #   part2: "part2",
  #   part3: "part3"
  # }

  validates :title, presence: true
  validates :part, presence: true
end
