class Course < ApplicationRecord
  has_many :course_accesses
  has_many :orders, dependent: :destroy
  has_many :users, through: :orders
  has_many :speaking_topics
  has_many :speaking_attempts
  has_many :course_progresses
  has_one_attached :thumbnail
  has_many :course_sections, inverse_of: :course, dependent: :destroy
  enum :status, { draft: 0, published: 1 }, suffix: true
  scope :published_courses, -> { where(status: statuses[:published]) }
  validates :title, presence: true
  validates :band_min, :band_max, allow_blank: true
  validates :price, presence: true
  validates :duration_days, presence: true, , on: :create
  validates :status, presence: true
  accepts_nested_attributes_for :course_sections, allow_destroy: true
end
