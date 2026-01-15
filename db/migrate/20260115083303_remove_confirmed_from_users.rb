class RemoveConfirmedFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :confirmed, :boolean
  end
end
