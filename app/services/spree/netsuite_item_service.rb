module Spree
  class NetsuiteItemService
    def self.format_item(item)
      { item: { id: item.variant.netsuite_item_id }, rate: rate_item(item), quantity: item.quantity,
        custcol_nff_line_item_shipping_weight: item.variant&.weight&.to_f, inventorylocation: { id: 1 },
        inventorysubsidiary: { id: 3 } }
    end

    private

    def self.rate_item(item)
      if item.variant.sale_price.present?
        current_currency ||= Spree::Config[:currency]
        item.variant.original_price_in(current_currency).amount.to_f
      else
        item.price.to_f
      end
    end
  end
end
