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
      end

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
        { status: 'B', payment_method_id: 8 }  # payment paid
      else
        { status: 'A', payment_method_id: 2 }  # payment pending
      end

    end

  end
end
