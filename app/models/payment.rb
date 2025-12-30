class Payment < ApplicationRecord
  belongs_to :course_access

  enum status: {
    pending: "pending",
    success: "success",
    failed: "failed"
  }

  validates :amount, presence: true
  validates :payment_method, presence: true
  validates :transaction_code, presence: true, uniqueness: true
end
