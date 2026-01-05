class Order < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_one :payment, dependent: :destroy
  has_one :course_access, dependent: :destroy

  enum :status, { pending: 0, paid: 1, failed: 2 }, suffix: true

  validates :total_price, presence: true
end
