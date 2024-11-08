require 'net/http'
require 'uri'
require 'json'

module Spree
  class NetsuiteUpdateLineItemService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}record/v1/salesOrder"

    def update(order)
      items = []
      
      order.line_items.each do |item|
        if item.variant.netsuite_item_id.present?
          discount_item = update_add_discount_item(item)
          item = Spree::NetsuiteItemService.format_item(item)
          items << item if item
          items << discount_item if discount_item
        else
          sku = item.variant.sku if item.variant.present?
          item_id = Spree::NetsuiteSearchSkuService.new.search_by_sku(sku) if sku.present?
          if item_id.present?
            item.variant.update(netsuite_item_id: item_id)
            discount_item = update_add_discount_item(item)
            item = Spree::NetsuiteItemService.format_item(item)
            items << item if item
            items << discount_item if discount_item
          else
            Spree::NetsuiteMailer.notify_netsuite(order: order).deliver_now
            return
          end
        end
      end

      items = add_route_insurance_item(items, order)
      items = add_order_header_level_discount(items, order)
      items

      payment = payment_method(order)
      return if payment.nil?

      uri = URI.parse("#{BASE_URL}/#{order.netsuite_sales_order_id}")
      params = { replace: "item" }
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Patch.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = generate_oauth_header(uri, 'PATCH')

      request.body = {
        shippingCost: order.shipment_total.to_f,
        item: {
          items: items
        },
        orderstatus: payment[:status],
        shipmethod: { id: 66857 },
        shippingcost: order.shipment_total.to_f,
        shippingAddress: shipping_address(order.ship_address),
        paymentoption: {
          id: payment[:payment_method_id]
        }
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        response.body.present? ? JSON.parse(response.body) : {}
      else
        { error: "Request failed with response code #{response.code}", body: response.body }
      end

    end

    private

    def update_add_discount_item(item)
      if item.variant.sale_price.present?
        discount_item = { item: { id: 7 }, rate: -item_rate(item) , price: { id: -1 }, description: 'For: ' + item.name}
      end
    end

    def item_rate(item)
      current_currency ||= Spree::Config[:currency]
      (item.variant.original_price_in(current_currency).amount.to_f - item.variant.sale_price.to_f) * item.quantity
    end

    def add_route_insurance_item(items, order)
      if order.route_insurance_selected == true
        item = { item: { id: 8 }, rate: order.route_insurance_price.to_f}
        items << item
        items
      else
        items
      end
    end

    def add_order_header_level_discount(items, order)
      if order.adjustment_total != 0 && !gift_card_applied(order).present?
        item = { item: { id: 7 }, rate: order.adjustment_total.to_f, price: { id: -1 } }
        items << item
      elsif order.adjustment_total == 0 && gift_card_applied(order).present?
        item = { item: { id: 7 }, rate: gift_card_amount(order), price: { id: -1 } }
        items << item
      elsif order.adjustment_total != 0 && gift_card_applied(order).present?
        rate = (order.adjustment_total.to_f + gift_card_amount(order))
        item = { item: { id: 7 }, rate: rate , price: { id: -1 }}
        items << item
      else
        items
      end
    end

    def gift_card_applied(order)
      order.payments.any? { |payment| payment.payment_method.type == "Spree::PaymentMethod::GiftCard" }
    end

    def gift_card_amount(order)
      order.display_total_applied_gift_card.money.to_f
    end

    def verify_line_items(order)
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
    end

    def shipping_address(address)
      {
        addressee: address.full_name,
        addr1: address.address1,
        addr2: address.address2,
        city: address.city,
        state: address.state.abbr,
        zip: address.zipcode,
        country: address.country.iso
      }
    end

    def payment_method(order)
      if order.paid?
        { status: 'B', payment_method_id: @online_payment }  # payment paid
      else
        { status: 'A', payment_method_id: @check_payment }  # payment pending
      end

    end

  end
end
