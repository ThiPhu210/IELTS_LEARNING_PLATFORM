class AddOrderToCourseAccesses < ActiveRecord::Migration[8.0]
  def change
    add_reference :course_accesses, :order, null: false, foreign_key: true
  end
end
