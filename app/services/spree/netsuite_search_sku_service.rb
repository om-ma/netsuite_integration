require 'net/http'
require 'uri'
require 'openssl'
require 'securerandom'
require 'json'

module Spree
  class NetsuiteSearchSkuService < NetsuiteBaseService
    BASE_URL = "#{NetsuiteBaseService::BASE_URL}query/v1/suiteql"

    def search_by_sku(sku)
      uri = URI.parse(BASE_URL)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Prefer'] = 'transient'
      request['Authorization'] = generate_oauth_header(uri, 'POST')

      request.body = {
        "q": "SELECT id, itemId FROM item WHERE itemId = '#{sku}'"
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      begin
        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          response_data = JSON.parse(response.body)
          response_data['items'].any? ? response_data['items'][0]['id'] : {}
        else
          raise "HTTP Error: #{response.body}"
        end

      rescue JSON::ParserError => e
        puts "JSON parsing error: #{e.message}"
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
      end
    end
  end
end

