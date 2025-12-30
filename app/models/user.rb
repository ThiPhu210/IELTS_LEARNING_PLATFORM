class User < ApplicationRecord
  has_secure_password   
  has_many :course_accesses
  has_many :courses, through: :course_accesses

  has_many :speaking_attempts
  has_many :course_progresses
  has_one :teacher_profile, dependent: :destroy

  enum :role, { admin: 0, teacher: 1, student: 2 }, suffix: true

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
end
