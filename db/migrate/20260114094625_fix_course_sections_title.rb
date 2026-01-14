class FixCourseSectionsTitle < ActiveRecord::Migration[7.1]
  def change
    remove_column :course_sections, :title, :text
    add_column :course_sections, :title, :string
  end
end
