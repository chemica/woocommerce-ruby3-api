# frozen_string_literal: true

require "httparty"
require "json"
require "cgi"
require "addressable/uri"

require "woocommerce_api/oauth"
require "woocommerce_api/version"

module WooCommerce
  class ApiBase
    DEFAULT_ARGS = {
      wp_api: false, version: "v3", verify_ssl: true,
      signature_method: "HMAC-SHA256", httparty_args: {}
    }.freeze
    SENSITIVE_ARGS = [:@consumer_key, :@consumer_secret, :@signature_method].freeze

    def initialize(url, consumer_key, consumer_secret, args = {})
      @url = url
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret

      args = DEFAULT_ARGS.merge(args)
      create_args_variables(args)

      @is_ssl = @url.start_with? "https"
    end

    # Overrides inspect to hide sensitive information
    #
    # Returns a string representation of the object
    def inspect
      safe_ivars = instance_variables.each_with_object({}) do |var, hash|
        value = instance_variable_get(var)
        hash[var] = SENSITIVE_ARGS.include?(var) ? "[FILTERED]" : value
      end

      "#<#{self.class}:0x#{object_id.to_s(16)} #{safe_ivars.map { |k, v| "#{k}=#{v.inspect}" }.join(', ')}>"
    end

    private

    # Internal: Sets authentication options for SSL requests
    #
    # options - The options hash to modify with authentication settings
    #
    # Returns the modified options hash
    def authentication_options(options)
      options[:verify] = @verify_ssl

      if @query_string_auth
        options[:query] = { consumer_key: @consumer_key, consumer_secret: @consumer_secret }
      else
        options[:basic_auth] = { username: @consumer_key, password: @consumer_secret }
      end
      options
    end

    # Internal: Creates instance variables from a hash of arguments
    #
    # args - A hash of arguments to create instance variables from
    #
    # Returns nothing
    def create_args_variables(args)
      @wp_api = args[:wp_api]
      @version = args[:version]
      @verify_ssl = args[:verify_ssl] == true
      @signature_method = args[:signature_method]
      @debug_mode = args[:debug_mode]
      @query_string_auth = args[:query_string_auth]
      @httparty_args = args[:httparty_args]
    end

    # Internal: Appends data as query params onto an endpoint
    #
    # endpoint - A String naming the request endpoint.
    # data     - A hash of data to flatten and append
    #
    # Returns an endpoint string with the data appended
    def add_query_params(endpoint, data)
      return endpoint if data.nil? || data.empty?

      endpoint += "?" unless endpoint.include? "?"
      endpoint += "&" unless endpoint.end_with? "?"
      endpoint + Addressable::URI.encode(flatten_hash(data).join("&"))
    end

    # Internal: Get URL for requests
    #
    # endpoint - A String naming the request endpoint.
    # method   - The method used in the url (for oauth querys)
    #
    # Returns the endpoint String.
    def get_url(endpoint, method)
      api = @wp_api ? "wp-json" : "wc-api"
      url = @url
      url = "#{url}/" unless url.end_with? "/"
      url = "#{url}#{api}/#{@version}/#{endpoint}"

      @is_ssl ? url : oauth_url(url, method)
    end

    # Internal: Generates an oauth url given current settings
    #
    # url    - A String naming the current request url
    # method - The HTTP verb of the request
    #
    # Returns a url to be used for the query.
    def oauth_url(url, method)
      oauth = WooCommerce::OAuth.new(
        url,
        method,
        @version,
        {
          consumer_key: @consumer_key, consumer_secret: @consumer_secret,
          signature_method: @signature_method
        }
      )
      oauth.oauth_url
    end

    # Internal: Flattens a hash into an array of query relations
    #
    # hash - A hash to flatten
    #
    # Returns an array full of key value paired strings
    def flatten_hash(hash)
      hash.flat_map do |key, value|
        case value
        when Hash
          remap_to_inner_hash(key, value)
        when Array
          value.map { |inner_value| "#{key}[]=#{inner_value}" }
        else
          "#{key}=#{value}"
        end
      end
    end

    # Internal: Remaps a hash to an array of key value paired strings
    # used internally for flatten_hash
    #
    # key    - A String naming the key
    # value  - A Hash to remap
    #
    # Returns an array full of key value paired strings
    def remap_to_inner_hash(key, value)
      value.map do |inner_key, inner_value|
        "#{key}[#{inner_key}]=#{inner_value}"
      end
    end

    # Internal: Requests default options.
    #
    # method   - A String naming the request method
    # endpoint - A String naming the request endpoint.
    # data     - The Hash data for the request.
    #
    # Returns the response in JSON String.
    def do_request(method, endpoint, data = {})
      url = get_url(endpoint, method)
      options = {
        format: :json
      }

      # Allow custom HTTParty args.
      options = options.merge(@httparty_args)

      add_headers(options, data)
      authentication_options(options) if @is_ssl

      options[:debug_output] = $stdout if @debug_mode
      options[:body] = data.to_json unless data.empty?

      HTTParty.send(method, url, options)
    end

    # Internal: Adds headers to the request options
    # used internally for do_request
    #
    # options - The options hash to modify with headers
    # data    - The data for the request
    #
    # Returns the modified options hash
    def add_headers(options, data)
      options[:headers] = {
        "User-Agent" => "WooCommerce API Client-Ruby/#{WooCommerce::VERSION}",
        "Accept" => "application/json"
      }
      options[:headers]["Content-Type"] = "application/json;charset=utf-8" unless data.empty?
    end
  end

  # Initialize the API class
  #
  # @param url [String] The base URL of the WooCommerce store
  # @param consumer_key [String] The consumer key for the API
  # @param consumer_secret [String] The consumer secret for the API
  # @param args [Hash] Additional configuration options

  class API < ApiBase
    # Public: GET requests.
    #
    # endpoint - A String naming the request endpoint.
    # query    - A Hash with query params.
    #
    # Returns the request Hash.
    def get(endpoint, query = nil)
      do_request :get, add_query_params(endpoint, query)
    end

    # Public: POST requests.
    #
    # endpoint - A String naming the request endpoint.
    # data     - The Hash data for the request.
    #
    # Returns the request Hash.
    def post(endpoint, data)
      do_request :post, endpoint, data
    end

    # Public: PUT requests.
    #
    # endpoint - A String naming the request endpoint.
    # data     - The Hash data for the request.
    #
    # Returns the request Hash.
    def put(endpoint, data)
      do_request :put, endpoint, data
    end

    # Public: DELETE requests.
    #
    # endpoint - A String naming the request endpoint.
    # query    - A Hash with query params.
    #
    # Returns the request Hash.
    def delete(endpoint, query = nil)
      do_request :delete, add_query_params(endpoint, query)
    end

    # Public: OPTIONS requests.
    #
    # endpoint - A String naming the request endpoint.
    #
    # Returns the request Hash.
    def options(endpoint)
      do_request :options, add_query_params(endpoint, nil)
    end
  end
end
