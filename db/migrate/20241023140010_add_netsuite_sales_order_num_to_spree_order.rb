class AddNetsuiteSalesOrderNumToSpreeOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :netsuite_sales_order_num, :string
  end
end