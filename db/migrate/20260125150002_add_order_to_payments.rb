class AddOrderToPayments < ActiveRecord::Migration[7.1]
  def change
    add_reference :payments, :order, foreign_key: true
  end
end
