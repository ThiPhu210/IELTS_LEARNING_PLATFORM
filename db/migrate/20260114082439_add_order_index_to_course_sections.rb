class AddOrderIndexToCourseSections < ActiveRecord::Migration[8.0]
  def change
    add_column :course_sections, :order_index, :integer
  end
end
