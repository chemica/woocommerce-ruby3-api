# frozen_string_literal: true

require_relative "test_helper"

class WooCommerceAPITest < Minitest::Test
  def setup
    @basic_auth = WooCommerce::API.new(
      "https://dev.test/",
      "user",
      "pass"
    )

    @oauth = WooCommerce::API.new(
      "http://dev.test/",
      "user",
      "pass"
    )
  end

  def test_basic_auth_get
    stub_request(:get, "https://dev.test/wc-api/v3/customers")
      .with(headers: { "Authorization" => "Basic dXNlcjpwYXNz" })
      .to_return(status: 200, body: '{"customers":[]}', headers: { "Content-Type" => "application/json" })

    response = @basic_auth.get "customers"

    assert_equal 200, response.code
  end

  def test_oauth_get
    stub_request(:get, %r{http://dev\.test/wc-api/v3/customers\?oauth_consumer_key=user})
      .to_return(status: 200, body: '{"customers":[]}', headers: { "Content-Type" => "application/json" })

    response = @oauth.get "customers"

    assert_equal 200, response.code
  end

  def test_oauth_get_puts_data_in_alpha_order
    stub_request(:get, %r{http://dev\.test/wc-api/v3/customers\?abc=123&oauth_consumer_key=user})
      .to_return(status: 200, body: '{"customers":[]}', headers: { "Content-Type" => "application/json" })

    response = @oauth.get "customers", abc: "123", oauth_d: "456", xyz: "789"

    assert_equal 200, response.code
  end

  def test_basic_auth_post
    stub_request(:post, "https://dev.test/wc-api/v3/products")
      .with(
        headers: { "Authorization" => "Basic dXNlcjpwYXNz" },
        body: { product: { title: "Testing product" } }.to_json
      )
      .to_return(status: 201, body: '{"products":[]}', headers: { "Content-Type" => "application/json" })

    data = {
      product: {
        title: "Testing product"
      }
    }
    response = @basic_auth.post "products", data

    assert_equal 201, response.code
  end

  def test_oauth_post
    stub_request(:post, %r{http://dev\.test/wc-api/v3/products\?oauth_consumer_key=user})
      .to_return(status: 201, body: '{"products":[]}', headers: { "Content-Type" => "application/json" })

    data = {
      product: {
        title: "Testing product"
      }
    }
    response = @oauth.post "products", data

    assert_equal 201, response.code
  end

  def test_basic_auth_put
    stub_request(:put, "https://dev.test/wc-api/v3/products/1234")
      .with(
        headers: { "Authorization" => "Basic dXNlcjpwYXNz" },
        body: { product: { title: "Updating product title" } }.to_json
      )
      .to_return(status: 200, body: '{"customers":[]}', headers: { "Content-Type" => "application/json" })

    data = {
      product: {
        title: "Updating product title"
      }
    }
    response = @basic_auth.put "products/1234", data

    assert_equal 200, response.code
  end

  def test_oauth_put
    stub_request(:put, %r{http://dev\.test/wc-api/v3/products\?oauth_consumer_key=user})
      .to_return(status: 200, body: '{"products":[]}', headers: { "Content-Type" => "application/json" })

    data = {
      product: {
        title: "Updating product title"
      }
    }
    response = @oauth.put "products", data

    assert_equal 200, response.code
  end

  def test_basic_auth_delete
    stub_request(:delete, "https://dev.test/wc-api/v3/products/1234?force=true")
      .with(headers: { "Authorization" => "Basic dXNlcjpwYXNz" })
      .to_return(status: 202, body: '{"message":"Permanently deleted product"}', headers: { "Content-Type" => "application/json" })

    response = @basic_auth.delete "products/1234?force=true"

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.body
  end

  def test_basic_auth_delete_params
    stub_request(:delete, "https://dev.test/wc-api/v3/products/1234?force=true")
      .with(headers: { "Authorization" => "Basic dXNlcjpwYXNz" })
      .to_return(status: 202, body: '{"message":"Permanently deleted product"}', headers: { "Content-Type" => "application/json" })

    response = @basic_auth.delete "products/1234", force: true

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.body
  end

  def test_oauth_delete
    stub_request(:delete, %r{http://dev\.test/wc-api/v3/products/1234\?force=true&oauth_consumer_key=user})
      .to_return(status: 202, body: '{"message":"Permanently deleted product"}', headers: { "Content-Type" => "application/json" })

    response = @oauth.delete "products/1234?force=true"

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.body
  end

  def test_adding_query_params
    url = @oauth.send(:add_query_params, "foo.com", filter: { sku: "123" }, order: "created_at")

    assert_equal url, Addressable::URI.encode("foo.com?filter[sku]=123&order=created_at")
  end

  def test_invalid_signature_method
    assert_raises WooCommerce::OAuth::InvalidSignatureMethodError do
      client = WooCommerce::API.new("http://dev.test/", "user", "pass", signature_method: "GARBAGE")
      client.get "products"
    end
  end
end
