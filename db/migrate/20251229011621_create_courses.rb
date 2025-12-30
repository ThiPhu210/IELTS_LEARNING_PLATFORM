class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.float :band_min
      t.float :band_max
      t.decimal :price
      t.integer :duration_days
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
