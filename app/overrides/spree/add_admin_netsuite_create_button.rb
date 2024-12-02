Deface::Override.new(
  virtual_path: 'spree/admin/orders/_order_actions',
  name: 'add_admin_netsuite_create_button',
  insert_after: "erb[silent]:contains('content_for :page_actions')",
  partial: "spree/admin/orders/netsuite_sales_order_button"
)