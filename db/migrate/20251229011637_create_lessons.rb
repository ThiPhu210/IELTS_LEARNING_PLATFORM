class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title
      t.string :video_url
      t.integer :order_index

      t.timestamps
    end
  end
end
