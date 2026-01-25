class RemoveOrderFromCourseAccesses < ActiveRecord::Migration[7.1]
  def change
    remove_reference :course_accesses, :order, foreign_key: true
  end
end
