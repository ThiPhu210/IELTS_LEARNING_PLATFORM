class SpeakingQuestion < ApplicationRecord
  belongs_to :speaking_topic

  validates :preparation_time, numericality: { greater_than: 0 }
  validates :speaking_time, numericality: { greater_than: 0 }

  validates :question_text, length: { maximum: 1000 }
  validates :cue_card, length: { maximum: 1000 }
  validates :transcript, length: { maximum: 1000 }
  validates :feedback, length: { maximum: 1000 }
end
