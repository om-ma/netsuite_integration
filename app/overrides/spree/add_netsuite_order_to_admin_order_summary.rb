Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'add_netsuite_order_to_admin_order_summary',
  insert_before: "[data-hook='admin_order_tab_date_completed_title']",
  partial: "spree/admin/orders/netsuite_sales_order_num"
)
