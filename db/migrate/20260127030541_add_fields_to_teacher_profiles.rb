class AddFieldsToTeacherProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :teacher_profiles, :full_name, :string
  end
end
