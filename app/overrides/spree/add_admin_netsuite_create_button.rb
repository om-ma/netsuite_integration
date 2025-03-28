Deface::Override.new(
  virtual_path: 'spree/admin/orders/_order_actions',
  name: 'add_admin_netsuite_create_button_partial',
  insert_after: "[data-hook='create_route_order']",
  partial: "spree/admin/orders/netsuite_sales_order_button"
)
