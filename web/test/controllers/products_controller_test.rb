# frozen_string_literal: true

require "test_helper"

class ProductsControllerTestTest < ActionDispatch::IntegrationTest
  # From fixture data
  KNOWN_SHOP = "regular-shop.myshopify.com"

  USER_ID = "1"

  JWT_PAYLOAD = {
    iss: "https://#{KNOWN_SHOP}/admin",
    dest: "https://#{KNOWN_SHOP}",
    aud: ShopifyAPI::Context.api_key,
    sub: USER_ID,
    exp: (Time.now + 1.days).to_i,
    nbf: 1234,
    iat: 1234,
    jti: "4321",
    sid: "abc123",
  }

  SESSION = ShopifyAPI::Auth::Session.new(
    shopify_session_id: "#{KNOWN_SHOP}_#{USER_ID}",
    shop: KNOWN_SHOP,
    is_online: true,
    access_token: "access-token",
  )

  setup do
    ShopifyAPI::Context.load_rest_resources(api_version: "2022-04")
  end

  test "handles creating products" do
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:post, "https://regular-shop.myshopify.com/admin/api/2022-04/graphql.json")
      .with(headers: { "X-Shopify-Access-Token" => "access-token" })
      .to_return(status: 200, body: JSON.dump({}))

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      get "/api/products/create",
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response :success
      assert_equal({ "success" => true, "error" => nil }, JSON.parse(@response.body))
    end
  end

  test "handles product creation errors" do
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:post, "https://regular-shop.myshopify.com/admin/api/2022-04/graphql.json")
      .with(headers: { "X-Shopify-Access-Token" => "access-token" })
      .to_return(status: 400, body: JSON.dump({ errors: "Something went wrong" }))

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      get "/api/products/create",
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response :bad_request
      assert_equal({ "success" => false, "error" => "Something went wrong" }, JSON.parse(@response.body))
    end
  end

  test "makes successful count request" do
    response_body = { count: 10 }
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:get, "https://regular-shop.myshopify.com/admin/api/2022-04/products/count.json")
      .with(headers: { "X-Shopify-Access-Token" => "access-token" })
      .to_return(status: 200, body: JSON.dump(response_body))

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      get "/api/products/count",
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response :success
      assert_match "application/json", @response.headers["Content-Type"]
      assert_equal(JSON.dump(response_body), @response.body)
    end
  end

  test "responds with re-auth headers if no session is available" do
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, nil) do
      get "/api/products/count",
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response 401
      assert_match "1", @response.headers["X-Shopify-API-Request-Failure-Reauthorize"]
      assert_match "/api/auth?shop=#{KNOWN_SHOP}", @response.headers["X-Shopify-API-Request-Failure-Reauthorize-Url"]
    end
  end
end
