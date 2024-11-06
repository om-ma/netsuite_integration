module Spree
  class NetsuiteApiService
    def self.create(order)
      items = []
      order.line_items.each do |item|
        if item.variant.netsuite_item_id.present?
          discount_item = add_discount_item(item)
          item = Spree::NetsuiteItemService.format_item(item)
          items << item if item
          items << discount_item if discount_item
        else
          sku = item.variant.sku if item.variant.present?
          item_id = Spree::NetsuiteSearchSkuService.new.search_by_sku(sku) if sku.present?
          if item_id.present?
            item.variant.update(netsuite_item_id: item_id)
            discount_item = add_discount_item(item)
            item = Spree::NetsuiteItemService.format_item(item)
            items << item if item
            items << discount_item if discount_item
          else
            Spree::NetsuiteMailer.notify_netsuite(order: order).deliver_now
            return
          end
        end
        items = add_route_insurance_item(items, order)
        items = add_order_header_level_discount(items, order)
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

    private

    def self.add_discount_item(item)
      if item.variant.sale_price.present?
        discount_item = { item: { id: 7 }, rate: -item_rate(item.variant) , price: { id: -1 }, description: 'For: ' + item.name}
      end
    end

    def self.item_rate(variant)
      current_currency ||= Spree::Config[:currency]
      variant.original_price_in(current_currency).amount.to_f - variant.sale_price.to_f
    end

    def self.add_route_insurance_item(items, order)
      if order.route_insurance_selected == true
        item = { item: { id: 8 }, rate: order.route_insurance_price.to_f}
        items << item
        items
      else
        items
      end
    end

    def self.add_order_header_level_discount(items, order)
      if order.adjustment_total != 0 && !gift_card_applied(order).present?
        item = { item: { id: 7 }, rate: order.adjustment_total.to_f, price: { id: -1 } }
        items << item
      elsif order.adjustment_total == 0 && gift_card_applied(order).present?
        item = { item: { id: 7 }, rate: gift_card_amount(order), price: { id: -1 } }
        items << item
      elsif order.adjustment_total != 0 && gift_card_applied(order).present?
        rate = order.adjustment_total.to_f + gift_card_amount(order)
        item = { item: { id: 7 }, rate: rate , price: { id: -1 }}
        items << item
      else
        items
      end
    end

    def self.gift_card_applied(order)
      order.payments.any? { |payment| payment.payment_method.type == "Spree::PaymentMethod::GiftCard" }
    end

    def self.gift_card_amount(order)
      order.display_total_applied_gift_card.money.to_f
    end
  end
end
