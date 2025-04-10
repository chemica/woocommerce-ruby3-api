# frozen_string_literal: true

# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# Version is loaded directly to avoid circular requires
require_relative "lib/woocommerce_api/version"

Gem::Specification.new do |s|
  s.name        = "woocommerce_api"
  s.version     = WooCommerce::VERSION
  s.date        = "2025-10-04"

  s.summary     = "A Ruby wrapper for the WooCommerce API"
  s.description = "This gem provide a wrapper to deal with the WooCommerce REST API"
  s.license     = "MIT"

  s.authors     = ["Claudio Sanches"]
  s.email       = "claudio@automattic.com"
  s.files       = Dir["lib/woocommerce_api.rb", "lib/woocommerce_api/*.rb"]
  s.homepage    = "https://github.com/woocommerce/wc-api-ruby"
  s.required_ruby_version = ">= 3.0.2"

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_runtime_dependency "httparty", "~> 0.23.1"
  s.add_runtime_dependency "json", "~> 2.10.2", ">= 2.6.0"
  s.add_runtime_dependency "base64", "~> 0.2.0"
  s.add_runtime_dependency "addressable", "~> 2.8.1"
  
  s.add_development_dependency "rake", "~> 13.2.1"
  s.add_development_dependency "minitest", "~> 5.25.5"
  s.add_development_dependency "webmock", "~> 3.25.1"
  s.add_development_dependency "brakeman", "~> 7.0.2"
end
