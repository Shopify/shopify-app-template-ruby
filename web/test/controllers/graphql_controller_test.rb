# frozen_string_literal: true

require "test_helper"

class GraphqlControllerTestTest < ActionDispatch::IntegrationTest
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

  test "makes successful request" do
    response_body = { data: "GraphQL response" }
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:post, "https://regular-shop.myshopify.com/admin/api/2022-04/graphql.json")
      .with(
        body: JSON.dump({ query: "GraphQL query", variables: nil }),
        headers: { "X-Shopify-Access-Token" => "access-token" }
      )
      .to_return(status: 200, body: JSON.dump(response_body))

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      post "/api/graphql",
        as: :json,
        params: { query: "GraphQL query" },
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response :success
      assert_match "application/json", @response.headers["Content-Type"]
      assert_equal(JSON.dump(response_body), @response.body)
    end
  end

  test "propagates errors to client side" do
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:post, "https://regular-shop.myshopify.com/admin/api/2022-04/graphql.json")
      .with(
        body: JSON.dump({ query: "GraphQL query", variables: nil }),
        headers: { "X-Shopify-Access-Token" => "access-token" }
      )
      .to_return(status: 500)

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      post "/api/graphql",
        as: :json,
        params: { query: "GraphQL query" },
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response 500
      assert_match "application/json", @response.headers["Content-Type"]
    end
  end

  test "responds with re-auth headers if no session is available" do
    token = JWT.encode(JWT_PAYLOAD, ShopifyAPI::Context.api_secret_key, "HS256")

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, nil) do
      post "/api/graphql",
        as: :json,
        params: { query: "GraphQL query" },
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response 401
      assert_match "1", @response.headers["X-Shopify-API-Request-Failure-Reauthorize"]
      assert_match "/api/auth?shop=#{KNOWN_SHOP}", @response.headers["X-Shopify-API-Request-Failure-Reauthorize-Url"]
    end
  end

  test "responds with re-auth headers if session has expired" do
    payload = JWT_PAYLOAD.clone
    payload[:exp] = (Time.now - 1.hour).to_i
    token = JWT.encode(payload, ShopifyAPI::Context.api_secret_key, "HS256")
    stub_request(:post, "https://regular-shop.myshopify.com/admin/api/2022-04/graphql.json")
      .with(
        body: JSON.dump({ query: "GraphQL query", variables: nil }),
        headers: { "X-Shopify-Access-Token" => "access-token" }
      )
      .to_return(status: 401)

    ShopifyAPI::Utils::SessionUtils.stub(:load_current_session, SESSION) do
      post "/api/graphql",
        as: :json,
        params: { query: "GraphQL query" },
        xhr: true,
        headers: { "HTTP_AUTHORIZATION": "Bearer #{token}" }

      assert_response 401
      assert_match "1", @response.headers["X-Shopify-API-Request-Failure-Reauthorize"]
      assert_match "/api/auth?shop=#{KNOWN_SHOP}", @response.headers["X-Shopify-API-Request-Failure-Reauthorize-Url"]
    end
  end
end
