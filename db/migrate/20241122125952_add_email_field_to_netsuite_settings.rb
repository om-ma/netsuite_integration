class AddEmailFieldToNetsuiteSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_netsuite_settings, :exception_email_addresses, :jsonb, default: []
  end
end
