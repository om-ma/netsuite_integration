Deface::Override.new(
  virtual_path: "spree/admin/orders/index",
  name: "netsuite_sales_order_num_header",
  insert_after: "[data-hook='admin_orders_index_headers'] th:nth-child(2)",
  text: "<th><%= sort_link @search, :netsuite_sales_order_num, 'NetSuite Order Number' %></th>"
)

Deface::Override.new(
  virtual_path: "spree/admin/orders/index",
  name: "netsuite_sales_order_num_column",
  insert_after: "[data-hook='admin_orders_index_rows'] td:nth-child(1)",
  text: "<td><%= order.netsuite_sales_order_num %></td>"
)
