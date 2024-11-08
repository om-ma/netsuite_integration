class CreateSpreeNetsuiteSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_netsuite_settings do |t|
      t.integer :netsuite_entity_id
      t.integer :netsuite_location_id
      t.integer :netsuite_check_payment_method_id
      t.integer :netsuite_online_payment_method_id
      t.boolean :active

      t.timestamps
    end
  end
end
