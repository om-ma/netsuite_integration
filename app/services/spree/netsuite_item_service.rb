module Spree
  class NetsuiteItemService

    def self.format_item(item_id)
      item = Spree::LineItem.find item_id
      { item: { id: item.variant.netsuite_item_id }, rate: rate_item(item), quantity: item.quantity,
        custcol_nff_line_item_shipping_weight: item.variant&.weight&.to_f, inventorylocation: { id:  Spree::NetsuiteSetting.first.inventory_location_id },
        inventorysubsidiary: { id:  Spree::NetsuiteSetting.first.inventory_subsidiary_id } }
    end

    private

    def self.rate_item(item)
      if item.variant.respond_to?(:sale_price).present? && item.variant.sale_price.present?
        current_currency ||= Spree::Config[:currency]
        item.variant.original_price_in(current_currency).amount.to_f
      else
        item.price.to_f
      end
    end
  end
end
