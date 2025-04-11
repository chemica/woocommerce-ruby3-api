# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# Version is loaded directly to avoid circular requires
require_relative "lib/woocommerce_api/version"

Gem::Specification.new do |s|
  s.name        = "woocommerce-ruby3-api"
  s.version     = WooCommerce::VERSION

  s.summary     = "A Ruby 3+ wrapper for the WooCommerce API"
  s.description = "This gem provides a wrapper to access the WooCommerce REST API, optimized for Ruby 3+"
  s.license     = "MIT"

  s.authors     = ["Claudio Sanches", "Benjamin Randles-Dunkley"]
  s.email       = "ben@chemica.co.uk"

  # Files included in the gem
  s.files = Dir[
    "lib/**/*.rb",
    "README.md",
    "LICENSE",
    "*.gemspec"
  ]
  s.require_paths = ["lib"]

  s.homepage = "https://github.com/chemica/woocommerce-ruby3-api"
  s.required_ruby_version = ">= 3.1.0"

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.add_runtime_dependency "addressable", "~> 2.8.1"
  s.add_runtime_dependency "base64", "~> 0.2.0"
  s.add_runtime_dependency "httparty", "~> 0.23.1"
  s.add_runtime_dependency "json", "~> 2.10.2", ">= 2.6.0"

  s.add_development_dependency "bundler-audit", "~> 0.9.1"
  s.add_development_dependency "minitest", "~> 5.25.5"
  s.add_development_dependency "rake", "~> 13.2.1"
  s.add_development_dependency "rubocop", "~> 1.59.0"
  s.add_development_dependency "rubocop-minitest", "~> 0.34.5"
  s.add_development_dependency "rubocop-performance", "~> 1.20.1"
  s.add_development_dependency "webmock", "~> 3.25.1"
  s.metadata["rubygems_mfa_required"] = "true"
end
