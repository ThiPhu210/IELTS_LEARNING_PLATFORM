class Payment < ApplicationRecord
  belongs_to :order
  has_one :course_access, dependent: :destroy

  enum :status, { pending: 0, paid: 1, failed: 2 }, suffix: true
  scope :paid_payments, -> { where(status: statuses[:paid]) }
  validates :amount, presence: true
  validates :payment_method, presence: true
  validates :transaction_code,
          presence: true,
          if: -> { status == "paid" }

  # validate :paid_at_presence_if_paid

  # def paid_at_presence_if_paid
  #   if paid? && paid_at.blank?
  #     errors.add(:paid_at, "must exist when payment is paid")
  #   end
  # end
end
