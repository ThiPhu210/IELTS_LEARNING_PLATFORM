class Course < ApplicationRecord
  
  has_many :course_accesses
  has_many :users, through: :course_accesses
  has_many :lessons
  has_many :speaking_topics
  has_many :speaking_attempts
  has_many :course_progresses

  enum :status, { draft: 0, published: 1 }, suffix: true

  validates :title, presence: true
  validates :band_min, :band_max, presence: true
  validates :price, presence: true
  validates :duration_days, presence: true
  validates :status, presence: true
end
