class RemoveUserIdFromTeacherProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :teacher_profiles, :user_id, :integer
  end
end
