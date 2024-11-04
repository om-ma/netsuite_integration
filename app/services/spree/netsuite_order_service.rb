require 'net/http'
require 'uri'
require 'openssl'
require 'securerandom'
require 'json'

module Spree
  class NetsuiteOrderService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}record/v1/salesOrder"

    def create_order(order, items)
      payment = payment_method(order)
      return if payment.nil?
      uri = URI.parse(BASE_URL)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = generate_oauth_header(uri, 'POST')

      request.body = {
        entity: { id: 483 },
        custbody_nff_web_order_number: "#{Rails.env}-#{order.number}",
        item: {
          items: items
        },
        location: { id: 2 },
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
      if response.code == '204'
        netsuite_order_data = Spree::GetNetsuiteSalesOrderService.new.get_order(order.number)
        if netsuite_order_data.present?
          order.update(netsuite_sales_order_num: netsuite_order_data['tranid'],
                       netsuite_sales_order_id: netsuite_order_data['id']
                      )
        end
      end
    end

    private

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
      payment = order.payments.find do |p|
        p.payment_method.type == "Spree::PaymentMethod::Check"
      end
      if payment.present?
        { status: 'A', payment_method_id: 2 }  # Check payment
      else
        { status: 'B', payment_method_id: 8 }  # Default payment method
      end
    end
  end
end

