class Achievement < ApplicationRecord
  belongs_to :user
  has_one_attached :result
  validates :title, presence: true
  validates :year, presence: true
  validates :ielts_overall_band,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 9 },
            allow_nil: true
  scope :high_band, -> { where("ielts_overall_band > ?", 7) }
  scope :sorted_by_band, -> { order(ielts_overall_band: :desc) }
end
