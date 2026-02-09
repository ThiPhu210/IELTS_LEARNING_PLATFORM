class SpeakingQuestion < ApplicationRecord
  belongs_to :speaking_topic

  validates :preparation_time,
            numericality: { greater_than: 0 },
            allow_blank: true

  validates :speaking_time,
            numericality: { greater_than: 0 },
            allow_blank: true

  validates :question_text,
            length: { maximum: 1000 },
            allow_blank: true

  validates :cue_card,
            length: { maximum: 1000 },
            allow_blank: true
end
