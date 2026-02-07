class Order < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :destroy
  has_one :latest_payment,
        -> { order(created_at: :desc) },
        class_name: "Payment"
  enum :status, { pending: 0, paid: 1, failed: 2 }, suffix: true

  validates :total_price, presence: true
end
