class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :course_section, null: false, foreign_key: true
      t.string :title
      t.integer :duration

      t.timestamps
    end
  end
end
