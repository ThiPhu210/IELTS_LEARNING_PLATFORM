class CreateTeacherProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :teacher_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.text :bio
      t.string :expertise
      t.integer :experience_years

      t.timestamps
    end
  end
end
