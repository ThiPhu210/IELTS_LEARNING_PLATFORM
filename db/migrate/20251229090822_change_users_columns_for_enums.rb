class ChangeUsersColumnsForEnums < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :role, :integer, null: false, default: 2   # 2 = student
    change_column :users, :status, :integer, null: false, default: 0 # 0 = active
    change_column :users, :password_digest, :string, null: false
  end
end
