class AddDetailedScoresToSpeakingAttempts < ActiveRecord::Migration[8.0]
  def change
    add_column :speaking_attempts, :strengths,         :text,  array: true, default: []
    add_column :speaking_attempts, :improvements,      :text,  array: true, default: []
    add_column :speaking_attempts, :sample_correction, :text
  end
end
