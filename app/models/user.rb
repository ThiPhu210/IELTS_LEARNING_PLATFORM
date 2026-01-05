class User < ApplicationRecord
  has_secure_password
  has_many :course_accesses
  has_many :courses, through: :course_accesses
  has_many :orders
  has_many :speaking_attempts
  has_many :course_progresses
  has_one :teacher_profile, dependent: :destroy
  accepts_nested_attributes_for :teacher_profile, allow_destroy: true

  enum :role, { admin: 0, teacher: 1, student: 2 }, suffix: true
  scope :teachers, -> { where(role: :teacher) }
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :full_name, presence: true

  validates :password, presence: true, on: :create
end
