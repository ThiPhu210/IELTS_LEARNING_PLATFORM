class SpeakingAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :speaking_topic

  enum part: {
    part1: "part1",
    part2: "part2",
    part3: "part3"
  }

  enum graded_by: {
    ai: "AI",
    teacher: "TEACHER"
  }

  enum status: {
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  validates :part, :graded_by, :status, presence: true

  validates :overall_band, presence: true
  validates :fluency_score, presence: true
  validates :lexical_score, presence: true
  validates :grammar_score, presence: true
  validates :pronunciation_score, presence: true
  validates :feedback, presence: true
  validates :graded_by, presence: true
  validates :status, presence: true
  validates :audio_url, presence: true
  validates :audio_url, format: { with: URI::regexp(%w[http https]), message: "must be a valid URL" }
  validates :overall_band, numericality: { greater_than: 0, less_than: 9 }
  validates :fluency_score, numericality: { greater_than: 0, less_than: 9 }
  validates :lexical_score, numericality: { greater_than: 0, less_than: 9 }
  validates :grammar_score, numericality: { greater_than: 0, less_than: 9 }
  validates :pronunciation_score, numericality: { greater_than: 0, less_than: 9 }

end
