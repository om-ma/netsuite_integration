require 'net/http'
require 'uri'
require 'openssl'
require 'json'

module Spree
  class NetsuiteLineNumbersService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}record/v1/salesOrder"

    def total_line_item(order)
      uri = URI.parse("#{BASE_URL}/#{order.netsuite_sales_order_id}/item")
      request = Net::HTTP::Get.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = generate_oauth_header(uri, 'GET')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        response = http.request(request)
        if response.is_a?(Net::HTTPSuccess)
          response_data = JSON.parse(response.body)
          line_numbers = [] 
           response_data['items'].map do |item|
            href = item['links'][0]['href']
            line_number = href.split('/').last
            line_numbers << line_number
          end
          line_numbers
          if line_numbers.present?
            Spree::NetsuiteCancelOrderService.new.cancel_order(order.netsuite_sales_order_id, line_numbers)
          end

        else
          raise "HTTP Error: #{response.body}"
        end
        line_items_count
      rescue JSON::ParserError => e
        puts "JSON parsing error: #{e.message}"
        []
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        []
      end
    end
  end
end
