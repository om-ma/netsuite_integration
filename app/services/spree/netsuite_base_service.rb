module Spree
  class NetsuiteBaseService
    BASE_URL = "https://#{ENV['NETSUITE_ACCOUNT_ID']}.suitetalk.api.netsuite.com/services/rest/"
    CONSUMER_KEY = ENV['NETSUITE_CONSUMER_KEY']
    CONSUMER_SECRET = ENV['NETSUITE_CONSUMER_SECRET']
    TOKEN_ID = ENV['NETSUITE_TOKEN_ID']
    TOKEN_SECRET = ENV['NETSUITE_TOKEN_SECRET']
    REALM = ENV['NETSUITE_ACCOUNT_ID']

    def initialize
      @consumer_key = CONSUMER_KEY
      @consumer_secret = CONSUMER_SECRET
      @token_key = TOKEN_ID
      @token_secret = TOKEN_SECRET
      @realm = REALM
    end

    def generate_oauth_header(uri, method)
      oauth_params = {
        oauth_consumer_key: @consumer_key,
        oauth_nonce: SecureRandom.hex,
        oauth_signature_method: "HMAC-SHA256",
        oauth_timestamp: Time.now.to_i.to_s,
        oauth_token: @token_key,
        oauth_version: "1.0"
      }

      base_string = "#{method.upcase}&#{CGI.escape(uri.to_s)}&" +
                    oauth_params.sort.map { |k, v| "#{CGI.escape(k.to_s)}%3D#{CGI.escape(v.to_s)}" }.join('%26')

      signing_key = "#{CGI.escape(@consumer_secret)}&#{CGI.escape(@token_secret)}"

      # Generate signature
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, signing_key, base_string)
      oauth_signature = CGI.escape(Base64.encode64(hmac))

      # Authorization header
      authorization_header = "OAuth realm=\"#{@realm}\""
      oauth_params.each do |key, value|
        authorization_header += ",#{key}=\"#{value}\""
      end
      authorization_header += ",oauth_signature=\"#{oauth_signature}\""

      authorization_header
    end
  end
end
