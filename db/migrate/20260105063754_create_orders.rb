class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.decimal :total_price, precision: 10, scale: 2
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
