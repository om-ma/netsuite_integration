class AddNetsuiteItemIdToVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_variants, :netsuite_item_id, :integer
  end
end
