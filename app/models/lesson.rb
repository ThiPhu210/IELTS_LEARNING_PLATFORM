class Lesson < ApplicationRecord
  belongs_to :course

  validates :title, presence: true
  validates :video_url, presence: true
  validates :order_index, presence: true

  validates :order_index, uniqueness: { scope: :course_id }
  validates :video_url, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }
  validates :video_url, length: { maximum: 2048 }
  validates :title, length: { maximum: 255 }
  validates :order_index, uniqueness: { scope: :course_id }
  validates :order_index, numericality: { greater_than: 0 }
end
