# frozen_string_literal: true

require_relative "test_helper"

class OauthTest < Minitest::Test
  def setup
    @oauth = WooCommerce::API.new(
      "http://dev.test/",
      "user",
      "pass"
    )
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

  def test_oauth_delete
    stub_request(:delete, %r{http://dev\.test/wc-api/v3/products/1234\?force=true&oauth_consumer_key=user})
      .to_return(status: 202, body: '{"message":"Permanently deleted product"}',
                 headers: { "Content-Type" => "application/json" })

    response = @oauth.delete "products/1234?force=true"

    assert_equal 202, response.code
    assert_equal '{"message":"Permanently deleted product"}', response.body
  end

  def test_adding_query_params
    url = @oauth.send(:add_query_params, "foo.com", filter: { sku: "123" }, order: "created_at")

    assert_equal url, Addressable::URI.encode("foo.com?filter[sku]=123&order=created_at")
  end

  def test_invalid_signature_method
    client = WooCommerce::API.new("http://dev.test/", "user", "pass", signature_method: "GARBAGE")
    assert_raises WooCommerce::OAuth::InvalidSignatureMethodError do
      client.get "products"
    end
  end

  def test_inspect_hides_sensitive_data
    assert_match(/consumer_key="\[FILTERED\]"/, @oauth.inspect)
    assert_match(/consumer_secret="\[FILTERED\]"/, @oauth.inspect)
    assert_match(/signature_method="\[FILTERED\]"/, @oauth.inspect)
    refute_match(/user/, @oauth.inspect)
    refute_match(/pass/, @oauth.inspect)
  end
end
