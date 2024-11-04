module Spree
  class NetsuiteItemService
    def self.format_item(item)
      { item: { id: item.variant.netsuite_item_id }, rate: item.price.to_f }
    end
  end
end