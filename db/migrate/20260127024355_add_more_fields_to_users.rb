class AddMoreFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :school, :string
    add_column :users, :feedback, :text
    add_column :users, :bio, :text
    add_column :users, :phone, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :province, :string
    add_column :users, :postal_code, :string
  end
end
