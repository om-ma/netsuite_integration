class AddUpdateNetsuiteFieldToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :is_updated_on_netsuite, :boolean, default: false
  end
end
