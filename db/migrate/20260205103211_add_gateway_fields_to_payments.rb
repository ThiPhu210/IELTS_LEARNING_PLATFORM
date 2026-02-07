class AddGatewayFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :gateway_order_id, :string
    add_column :payments, :gateway_request_id, :string
    add_column :payments, :gateway_name, :string
  end
  
end
