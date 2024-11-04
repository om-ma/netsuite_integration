module Spree
  class NetsuiteUpdateService
    def self.update(order)
      if order.netsuite_sales_order_id.present?
       Spree::NetsuiteLineNumbersService.new.total_line_item(order)
      else
        netsuite_order_data = Spree::GetNetsuiteSalesOrderService.new.get_order(order.number)
        if netsuite_order_data.present?
          order.update(netsuite_sales_order_num: netsuite_order_data['tranid'],
                       netsuite_sales_order_id: netsuite_order_data['id']
                      )
        end
        Spree::NetsuiteLineNumbersService.new.total_line_item(order)
      end    
    end
  end
end