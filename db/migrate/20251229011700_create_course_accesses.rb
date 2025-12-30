class CreateCourseAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :course_accesses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.string :status

      t.timestamps
    end
  end
end
