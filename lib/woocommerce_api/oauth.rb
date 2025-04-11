# frozen_string_literal: true

require "digest/sha1"
require "cgi"
require "uri"
require "base64"
require "openssl"
require "addressable/uri"

module WooCommerce
  class OAuth
    class InvalidSignatureMethodError < StandardError; end

    NONCE_LIFETIME = 15 * 60 # Woocommerce keeps nonces for 15 minutes

    def initialize(url, method, version, credentials)
      @url = url
      @method = method.upcase
      @version = version
      @consumer_key = credentials[:consumer_key]
      @consumer_secret = credentials[:consumer_secret]
      @signature_method = credentials[:signature_method]
    end

    # Public: Get OAuth url
    #
    # Returns the OAuth url.
    def oauth_url
      params = {}
      url = @url

      url = parse_params(url, params)
      create_oauth_params(params, url)

      query_string = create_query_string(params)

      "#{url}?#{query_string}"
    end

    protected

    def parse_params(url, params)
      return url unless url.include?("?")

      parsed_url = URI.parse(url)
      CGI.parse(parsed_url.query).each do |key, value|
        params[key] = value[0]
      end
      params = params.sort.to_h

      parsed_url.to_s.gsub(/\?.*/, "")
    end

    # Internal: Create the query string
    #
    # params - A Hash with the OAuth params.
    #
    # Returns the query string String.
    def create_query_string(params)
      Addressable::URI.encode(params.map { |key, value| "#{key}=#{value}" }.join("&"))
    end

    # Internal: Create the OAuth params
    #
    # params - A Hash with the OAuth params.
    #
    # Updates and returns the OAuth params Hash.
    def create_oauth_params(params, url)
      params["oauth_consumer_key"] = @consumer_key
      params["oauth_nonce"] = generate_nonce
      params["oauth_signature_method"] = @signature_method
      params["oauth_timestamp"] = Time.new.to_i
      params["oauth_signature"] = CGI.escape(generate_oauth_signature(params, url))
    end

    # Internal: Generate a nonce
    #
    # Returns the nonce String.
    def generate_nonce
      Digest::SHA1.hexdigest(((Time.new.to_f % NONCE_LIFETIME) + (Process.pid * NONCE_LIFETIME)).to_s)
    end

    # Internal: Generate the OAuth Signature
    #
    # params - A Hash with the OAuth params.
    # url    - A String with a URL
    #
    # Returns the oauth signature String.
    def generate_oauth_signature(params, url)
      base_request_uri = CGI.escape(url.to_s)
      query_params = []

      params.sort.map do |key, value|
        query_params.push("#{encode_param(key.to_s)}%3D#{encode_param(value.to_s)}")
      end

      query_string = query_params
                     .join("%26")
      string_to_sign = "#{@method}&#{base_request_uri}&#{query_string}"

      Base64.strict_encode64(OpenSSL::HMAC.digest(digest, consumer_secret, string_to_sign))
    end

    def consumer_secret
      if ["v1", "v2"].include? @version
        @consumer_secret
      else
        "#{@consumer_secret}&"
      end
    end

    # Internal: Digest object based on signature method
    #
    # Returns a digest object.
    def digest
      case @signature_method
      when "HMAC-SHA256" then OpenSSL::Digest.new("sha256")
      when "HMAC-SHA1" then OpenSSL::Digest.new("sha1")
      else
        raise InvalidSignatureMethodError
      end
    end

    # Internal: Encode param
    #
    # text - A String to be encoded
    #
    # Returns the encoded String.
    def encode_param(text)
      CGI.escape(text).gsub("+", "%20").gsub("%", "%25")
    end
  end
end
