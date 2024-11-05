module Spree
  class NetsuiteApiService
    def self.create(order)
      items = []
      order.line_items.each do |item|
        if item.variant.netsuite_item_id.present?
          item = Spree::NetsuiteItemService.format_item(item)
          items << item if item
        else
          sku = item.variant.sku if item.variant.present?
          item_id = Spree::NetsuiteSearchSkuService.new.search_by_sku(sku) if sku.present?
          if item_id.present?
            item.variant.update(netsuite_item_id: item_id)
            item = Spree::NetsuiteItemService.format_item(item)
            items << item if item
          else
            Spree::NetsuiteMailer.notify_netsuite(order: order).deliver_now
            return
          end
        end
        items
      end
      if items.present?
        begin
          Spree::NetsuiteOrderService.new.create_order(order, items)
        rescue StandardError => e
          Rails.logger.error("NetSuite order creation failed: #{e.message}")
        end
      end
    end
  end
end