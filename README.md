# WooCommerce Ruby 3 API

A Ruby wrapper for the WooCommerce REST API. Easily interact with the WooCommerce REST API using this library, optimized for Ruby 3.0+.

[![Gem Version](https://badge.fury.io/rb/woocommerce-ruby3-api.svg?bust=1)](https://badge.fury.io/rb/woocommerce-ruby3-api)
[![Tests](https://github.com/chemica/woocommerce-ruby3-api/actions/workflows/test.yml/badge.svg?branch=main&bust=1)](https://github.com/chemica/woocommerce-ruby3-api/actions/workflows/test.yml)


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
| `endpoint` | `String` | WooCommerce API endpoint, example: `