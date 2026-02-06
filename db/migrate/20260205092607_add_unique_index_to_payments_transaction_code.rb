class AddUniqueIndexToPaymentsTransactionCode < ActiveRecord::Migration[8.0]
  def change
    add_index :payments, :transaction_code, unique: true
  end
end
