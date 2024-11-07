require 'net/http'
require 'uri'
require 'openssl'
require 'securerandom'
require 'json'

module Spree
  class NetsuiteUpdatePaymentService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}record/v1/salesOrder"

    def update_order(order)
      uri = URI.parse("#{BASE_URL}/#{order.netsuite_sales_order_id}")
      request = Net::HTTP::Patch.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = generate_oauth_header(uri, 'PATCH')

      request.body = {
        orderstatus: "B"
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
  end
end

