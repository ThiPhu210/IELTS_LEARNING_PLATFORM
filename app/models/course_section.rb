class CourseSection < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy

  has_rich_text :description

  validates :title, presence: true
  validates :order_index,
            numericality: { greater_than: 0 },
            uniqueness: { scope: :course_id }

  before_validation :set_order_index, on: :create

  default_scope { order(order_index: :asc) }

  accepts_nested_attributes_for :lessons, allow_destroy: true

  private

  def set_order_index
    return if order_index.present?
    self.order_index = course.course_sections.maximum(:order_index).to_i + 1
  end
end
