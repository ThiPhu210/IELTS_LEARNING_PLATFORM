class CreateSpeakingAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :speaking_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :speaking_topic, null: false, foreign_key: true
      t.string :part
      t.string :audio_url
      t.text :transcript
      t.float :overall_band
      t.float :fluency_score
      t.float :lexical_score
      t.float :grammar_score
      t.float :pronunciation_score
      t.text :feedback
      t.string :graded_by
      t.string :status

      t.timestamps
    end
  end
end
