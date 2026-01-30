class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable
  has_many :orders, dependent: :destroy
  has_many :courses, through: :orders

  has_many :course_accesses
  has_many :speaking_attempts
  has_many :course_progresses
  has_one_attached :thumbnail

  enum :role, { admin: 0, student: 1 }, suffix: true
  has_many :achievements, dependent: :destroy
  scope :students, -> { where(role: :student) }
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :full_name, presence: true
  validates :password, presence: true, on: :create
  validates :school, presence: true, if: :student_role?



  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :feedback, length: { maximum: 1000 }, allow_blank: true
  validates :phone, length: { maximum: 10 }, allow_blank: true

  def has_course_access?(course)
    course_accesses.exists?(
      course_id: course.id,
      status: CourseAccess.statuses[:active]
    )
  end
end
