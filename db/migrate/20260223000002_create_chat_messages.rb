class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string     :role,   null: false   # "user" | "assistant"
      t.text       :content, null: false
      t.date       :sent_on, null: false  # để đếm giới hạn theo ngày

      t.timestamps
    end

    add_index :chat_messages, [:user_id, :course_id, :sent_on]
  end
end
