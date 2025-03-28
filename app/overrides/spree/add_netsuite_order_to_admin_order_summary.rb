Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'add_netsuite_order_to_admin_order_summary_table',
  insert_after: 'table#order_tab_summary > tbody.additional-info',
  partial: 'spree/admin/orders/netsuite_sales_order_num'
)