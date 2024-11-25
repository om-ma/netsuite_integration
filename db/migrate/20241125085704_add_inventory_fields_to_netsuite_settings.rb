class AddInventoryFieldsToNetsuiteSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_netsuite_settings, :inventory_location_id, :integer
    add_column :spree_netsuite_settings, :inventory_subsidiary_id, :integer
  end
end
