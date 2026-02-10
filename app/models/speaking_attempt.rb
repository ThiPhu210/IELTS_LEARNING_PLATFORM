class SpeakingAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :speaking_topic

  validates :part, presence: true
  validates :status, presence: true

  validates :audio_url, presence: true,
            format: { with: URI.regexp(%w[http https]) }

  validates :overall_band,
            :fluency_score,
            :lexical_score,
            :grammar_score,
            :pronunciation_score,
            numericality: { greater_than: 0, less_than: 9 },
            allow_nil: true

  validates :feedback, presence: false, allow_nil: true
end
