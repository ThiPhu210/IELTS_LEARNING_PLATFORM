class ChangeStatusToIntegerInCourses < ActiveRecord::Migration[8.0]
  def change
    change_column :courses, :status, :integer, default: 0, null: false, using: 'status::integer'
  end
end
