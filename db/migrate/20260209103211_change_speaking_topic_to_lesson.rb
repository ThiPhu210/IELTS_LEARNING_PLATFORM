class ChangeSpeakingTopicToLesson < ActiveRecord::Migration[7.1]
  def change
    remove_reference :speaking_topics, :course
    add_reference :speaking_topics, :lesson, foreign_key: true
  end
end
