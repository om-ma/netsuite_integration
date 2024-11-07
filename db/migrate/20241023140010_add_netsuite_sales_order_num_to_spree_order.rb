class AddNetsuiteSalesOrderNumToSpreeOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_orders, :netsuite_sales_order_num, :string
  end
end