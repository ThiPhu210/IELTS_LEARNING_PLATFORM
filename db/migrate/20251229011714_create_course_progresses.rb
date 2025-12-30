class CreateCourseProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :course_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.float :average_band
      t.datetime :last_practice_at

      t.timestamps
    end
  end
end
