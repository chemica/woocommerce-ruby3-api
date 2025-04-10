# frozen_string_literal: true

# Set up test environment without circular dependencies
require "minitest/autorun"
require "webmock/minitest"
require "json"
require "addressable/uri"

# Add the lib path to the load path
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "woocommerce_api"

# Disable real network connections in tests
WebMock.disable_net_connect! 