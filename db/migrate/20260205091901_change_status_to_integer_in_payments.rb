class ChangeStatusToIntegerInPayments < ActiveRecord::Migration[8.0]
  def change
    change_column :payments, :status, :integer, using: 'status::integer'
  end
end
