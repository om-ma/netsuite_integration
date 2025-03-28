require 'net/http'
require 'uri'
require 'openssl'
require 'securerandom'
require 'json'

module Spree
  class NetsuiteCancelOrderService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}record/v1/salesOrder"

    def cancel_order(netsuite_order_id, line_numbers)
      uri = URI.parse("#{BASE_URL}/#{netsuite_order_id}")
      request = Net::HTTP::Patch.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = generate_oauth_header(uri, 'PATCH')

      request.body = {
        item: {
          items: line_numbers.map do |line_number|
            {
              line: line_number.to_i,
              isclosed: true
            }
          end
        }
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      begin
        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          response.body.present? ? JSON.parse(response.body) : {}
        else
          { error: "Request failed with response code #{response.code}", body: response.body }
        end

      rescue StandardError => e
        { error: "An error occurred while attempting to cancel the order: #{e.message}" }
      end
    end
  end
end
