class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :year
      t.decimal :ielts_overall_band

      t.timestamps
    end
  end
end
