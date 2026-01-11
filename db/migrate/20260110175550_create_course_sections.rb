class CreateCourseSections < ActiveRecord::Migration[8.0]
  def change
    create_table :course_sections do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :position

      t.timestamps
    end
  end
end
