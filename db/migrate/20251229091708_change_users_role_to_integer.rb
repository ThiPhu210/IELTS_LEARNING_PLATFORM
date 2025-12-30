class ChangeUsersRoleToInteger < ActiveRecord::Migration[7.0]
  def up
    # Nếu cột role đang là string, convert sang integer
    execute <<-SQL
      ALTER TABLE users
      ALTER COLUMN role
      TYPE integer USING
      CASE role
        WHEN 'admin' THEN 0
        WHEN 'teacher' THEN 1
        WHEN 'student' THEN 2
        ELSE 2
      END
    SQL

    change_column_default :users, :role, 2
    change_column_null :users, :role, false

    execute <<-SQL
      ALTER TABLE users
      ALTER COLUMN status
      TYPE integer USING
      CASE status
        WHEN 'active' THEN 0
        WHEN 'suspended' THEN 1
        ELSE 0
      END
    SQL

    change_column_default :users, :status, 0
    change_column_null :users, :status, false
  end

  def down
    change_column :users, :role, :string
    change_column :users, :status, :string
  end
end
