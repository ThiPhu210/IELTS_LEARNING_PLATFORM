class ChangeStatusToIntegerInCourseAccesses < ActiveRecord::Migration[8.0]
  def change
    change_column :course_accesses,
                  :status,
                  :integer,
                  using: 'status::integer',
                  default: 0,
                  null: false
  end
end
