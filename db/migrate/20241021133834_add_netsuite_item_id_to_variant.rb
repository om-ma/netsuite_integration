class AddNetsuiteItemIdToVariant < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :netsuite_item_id, :integer
  end
end
