class User < ApplicationRecord
  devise :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable,
        :confirmable

  has_many :course_accesses
  has_many :courses, through: :orders
  has_many :orders, dependent: :destroy
  has_many :speaking_attempts
  has_many :course_progresses
  has_one :teacher_profile, dependent: :destroy

  has_one_attached :thumbnail
  accepts_nested_attributes_for :teacher_profile, allow_destroy: true

  enum :role, { admin: 0, teacher: 1, student: 2 }, suffix: true
  scope :teachers, -> { where(role: :teacher) }
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :full_name, presence: true
  validates :password, presence: true, on: :create
  def has_course_access?(course)
    course_accesses.exists?(
      course_id: course.id,
      status: "active"
    )
  end
end
