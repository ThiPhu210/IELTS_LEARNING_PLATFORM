class CreateSpeakingQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :speaking_questions do |t|
      t.references :speaking_topic, null: false, foreign_key: true
      t.text :question_text
      t.text :cue_card
      t.integer :preparation_time
      t.integer :speaking_time

      t.timestamps
    end
  end
end
