class RemoveGradedByFromSpeakingAttempts < ActiveRecord::Migration[8.0]
  def change
    remove_column :speaking_attempts, :graded_by, :string
  end
end
