class CourseAccess < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :destroy

  enum :status, { pending: 0, active: 1, expired: 2 }, suffix: true

  scope :active_access, -> { where(status: statuses[:active]) }

  validates :start_date, :end_date, :status, presence: true
  validates :user_id, uniqueness: { scope: :course_id }

  validates :end_date,
            comparison: { greater_than: :start_date }

  validate :start_date_not_in_past

  private

  def start_date_not_in_past
    if start_date.present? && start_date < Time.current - 1.minute
      errors.add(:start_date, "không được ở quá khứ")
    end
  end
end
