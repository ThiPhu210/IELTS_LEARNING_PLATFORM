class CreateSpeakingTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :speaking_topics do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title
      t.string :part
      t.string :status

      t.timestamps
    end
  end
end
