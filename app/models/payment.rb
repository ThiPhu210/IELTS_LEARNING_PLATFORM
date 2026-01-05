class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :course_access

  enum :status, { pending: 0, paid: 1, failed: 2 }, suffix: true
  scope :paid_payments, -> { where(status: statuses[:paid]) }
  validates :amount, presence: true
  validates :payment_method, presence: true
  validates :transaction_code, presence: true, uniqueness: true
end
