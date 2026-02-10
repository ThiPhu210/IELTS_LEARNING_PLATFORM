class CourseSection < ApplicationRecord
  belongs_to :course
  has_many :lessons, inverse_of: :course_section, dependent: :destroy

  has_rich_text :description

  validates :order_index,
            numericality: { greater_than: 0 },
            uniqueness: { scope: :course_id }

  before_validation :set_order_index, on: :create

  default_scope { order(order_index: :asc) }

  accepts_nested_attributes_for :lessons, allow_destroy: true

  private

def set_order_index
  return if order_index.present?

  max =
    course.course_sections
          .reject(&:marked_for_destruction?)
          .map(&:order_index)
          .compact
          .max.to_i

  self.order_index = max + 1
end

end
