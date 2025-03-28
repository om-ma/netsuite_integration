class AddShippingMethodIdToNetsuiteSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_netsuite_settings, :shipping_method_id, :integer
  end
end
