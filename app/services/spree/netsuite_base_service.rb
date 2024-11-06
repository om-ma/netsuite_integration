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
      raise "Consumer key missing" if @consumer_key.nil?
      raise "Consumer secret missing" if @consumer_secret.nil?
      raise "Token key missing" if @token_key.nil?
      raise "Token secret missing" if @token_secret.nil?
      raise "Realm missing" if @realm.nil?

      # Basic OAuth parameters
      oauth_params = {
        oauth_consumer_key: @consumer_key,
        oauth_nonce: SecureRandom.hex,
        oauth_signature_method: "HMAC-SHA256",
        oauth_timestamp: Time.now.to_i.to_s,
        oauth_token: @token_key,
        oauth_version: "1.0"
      }

      # Extract query parameters from URI and convert to a hash
      query_params = URI.decode_www_form(uri.query || "").to_h

      # Merge query parameters and OAuth parameters
      signature_params = oauth_params.merge(query_params)

      # Sort parameters by key, then by value
      sorted_params = signature_params.sort_by { |k, v| [k.to_s, v.to_s] }.map do |k, v|
        "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
      end.join('&')

      # Construct the base string
      base_string = "#{method.upcase}&#{CGI.escape(uri.scheme + '://' + uri.host + uri.path)}&#{CGI.escape(sorted_params)}"

      # Generate the signing key
      signing_key = "#{CGI.escape(@consumer_secret)}&#{CGI.escape(@token_secret)}"

      # Generate the signature
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, signing_key, base_string)
      oauth_signature = CGI.escape(Base64.encode64(hmac).strip)

      # Build the Authorization header
      authorization_header = "OAuth realm=\"#{@realm}\""
      oauth_params.each { |key, value| authorization_header += ",#{key}=\"#{value}\"" }
      authorization_header += ",oauth_signature=\"#{oauth_signature}\""
      authorization_header
    end
  end
end
