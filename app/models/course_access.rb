class CourseAccess < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :destroy

  enum status: {
    active: "active",
    expired: "expired",
    revoked: "revoked"
  }

  validates :start_date, :end_date, presence: true
  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :course_id }
  validates :start_date, :end_date, comparison: { greater_than: :start_date }
  validates :start_date, :end_date, comparison: { less_than: :end_date }
  validates :start_date, :end_date, comparison: { greater_than: Time.current }
end
