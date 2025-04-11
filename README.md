# WooCommerce Ruby 3 API

A Ruby wrapper for the WooCommerce REST API. Easily interact with the WooCommerce REST API using this library, optimized for Ruby 3.0+.

[![Gem Version](https://badge.fury.io/rb/woocommerce-ruby3-api.svg)](https://badge.fury.io/rb/woocommerce-ruby3-api) 
[![Tests](https://github.com/chemica/woocommerce-ruby3-api/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/chemica/woocommerce-ruby3-api/actions/workflows/test.yml)

## About

This is a fork of the [WooCommerce REST API - Ruby Client](https://github.com/woocommerce/wc-api-ruby) that has been updated to be compatible with modern Ruby versions (3.1+).

Key changes from the original:
- Fixed deprecated `URI.encode` calls using `Addressable::URI`
- Added explicit dependency on `base64` gem for Ruby 3.4+ compatibility
- All tests updated to use webmock instead of fakeweb
- Improved test organization
- Modern CI workflow with GitHub Actions
- Automated dependency updates with Dependabot
- Security scanning with bundler-audit

## Installation

```
gem install woocommerce-ruby3-api
```

Or with Bundler:

```
gem 'woocommerce-ruby3-api'
```

## Getting started

Generate API credentials (Consumer Key & Consumer Secret) in your WooCommerce store. Instructions: <https://woocommerce.com/document/woocommerce-rest-api/>.

Check out the WooCommerce API endpoints and data that can be manipulated in <https://woocommerce.github.io/woocommerce-rest-api-docs/>.

## Setup

Setup for the WP REST API (recommended):

```ruby
require "woocommerce-ruby3-api"

woocommerce = WooCommerce::API.new(
  "https://example.com",
  "consumer_key",
  "consumer_secret",
  {
    wp_api: true,
    version: "wc/v3"
  }
)
```

Setup for the WooCommerce legacy API:

```ruby
require "woocommerce-ruby3-api"

woocommerce = WooCommerce::API.new(
  "https://example.com",
  "consumer_key",
  "consumer_secret",
  {
    version: "v3"
  }
)
```

### Options

|       Option      |   Type   | Required |               Description                |
| ----------------- | -------- | -------- | ---------------------------------------- |
| `url`             | `String` | yes      | Your Store URL, example: https://example.com/ |
| `consumer_key`    | `String` | yes      | Your API consumer key                    |
| `consumer_secret` | `String` | yes      | Your API consumer secret                 |
| `args`            | `Hash`   | no       | Extra arguments (see Args options table) |

#### Args options

|        Option       |   Type   | Required |                                                 Description                                                  |
|---------------------|----------|----------|--------------------------------------------------------------------------------------------------------------|
| `wp_api`            | `Bool`   | no       | Allow requests to the WP REST API (WooCommerce 2.6 or later)                                                 |
| `version`           | `String` | no       | API version, default is `v3`                                                                                 |
| `verify_ssl`        | `Bool`   | no       | Verify SSL when connect, use this option as `false` when need to test with self-signed certificates          |
| `signature_method`  | `String` | no       | Signature method used for oAuth requests, works with `HMAC-SHA1` and `HMAC-SHA256`, default is `HMAC-SHA256` |
| `query_string_auth` | `Bool`   | no       | Force Basic Authentication as query string when `true` and using under HTTPS, default is `false`             |
| `debug_mode`        | `Bool`   | no       | Enables HTTParty debug mode                                                                                  |
| `httparty_args`     | `Hash`   | no       | Allows extra HTTParty args                                                                                   |

## Methods

|   Params   |   Type   |                         Description                          |
| ---------- | -------- | ------------------------------------------------------------ |
| `endpoint` | `String` | WooCommerce API endpoint, example: `customers` or `order/12` |
| `data`     | `Hash`   | Only for POST and PUT, data that will be converted to JSON   |
| `query`    | `Hash`   | Only for GET and DELETE, request query string                |

### GET

- `.get(endpoint, query)`

```ruby
# Get all customers
woocommerce.get "customers"

# Get a specific customer
woocommerce.get "customers/1"

# Get with parameters
woocommerce.get "customers", status: "processing"
```

### POST

- `.post(endpoint, data)`

```ruby
# Create a customer
data = {
  customer: {
    email: "john.doe@example.com",
    first_name: "John",
    last_name: "Doe",
    billing_address: {
      first_name: "John",
      last_name: "Doe",
      company: "",
      address_1: "969 Market",
      address_2: "",
      city: "San Francisco",
      state: "CA",
      postcode: "94103",
      country: "US",
      email: "john.doe@example.com",
      phone: "(555) 555-5555"
    },
    shipping_address: {
      first_name: "John",
      last_name: "Doe",
      company: "",
      address_1: "969 Market",
      address_2: "",
      city: "San Francisco",
      state: "CA",
      postcode: "94103",
      country: "US"
    }
  }
}

woocommerce.post "customers", data
```

### PUT

- `.put(endpoint, data)`

```ruby
# Update a customer
data = {
  customer: {
    last_name: "Doe"
  }
}

woocommerce.put "customers/1", data
```

### DELETE

- `.delete(endpoint, query)`

```ruby
# Delete a customer
woocommerce.delete "customers/1"

# Force delete a customer
woocommerce.delete "customers/1", force: true
```

### OPTIONS

- `.options(endpoint)`

#### Response

All methods will return [HTTParty::Response](https://github.com/jnunemaker/httparty) object.

```ruby
response = woocommerce.get "customers"

puts response.parsed_response # A Hash of the parsed JSON response
# Example: {"customers"=>[{"id"=>8, "created_at"=>"2015-05-06T17:43:51Z", "email"=>...

puts response.code # A Integer of the HTTP code response
# Example: 200

puts response.headers["x-wc-total"] # Total of items
# Example: 2

puts response.headers["x-wc-totalpages"] # Total of pages
# Example: 1
```

## Release History

### Ruby 3 Version (woocommerce-ruby3-api)
- 2025-10-04 - 1.5.0 - Initial fork with Ruby 3+ compatibility using Addressable::URI and base64 gem

### Original Project (woocommerce_api)
- 2016-12-14 - 1.4.0 - Introduces `httparty_args` arg and fixed compatibility with WordPress 4.7.
- 2016-09-15 - 1.3.0 - Added the `query_string_auth` and `debug_mode` options.
- 2016-06-26 - 1.2.1 - Fixed oAuth signature for WP REST API.
- 2016-05-09 - 1.2.0 - Added support for WP REST API and added method to do HTTP OPTIONS requests.
- 2015-12-07 - 1.1.2 - Stop send `body` in GET and DELETE requests.
- 2015-12-07 - 1.1.1 - Fixed the encode when have spaces in the URL parameters.
- 2015-08-27 - 1.1.0 - Added `query` argument for GET and DELETE methods, reduced chance of nonce collisions and added support for urls including ports.
- 2015-08-27 - 1.0.3 - Encode all % characters in query string for OAuth 1.0a.
- 2015-08-12 - 1.0.2 - Fixed the release date.
- 2015-08-12 - 1.0.1 - Escaped oauth_signature in url query string.
- 2015-07-15 - 1.0.0 - Stable release.
- 2015-07-15 - 0.0.1 - Beta release.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the [MIT License](LICENSE).
