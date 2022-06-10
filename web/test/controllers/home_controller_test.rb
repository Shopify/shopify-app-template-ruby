# frozen_string_literal: true

require "test_helper"

class HomeControllerTestTest < ActionDispatch::IntegrationTest
  # From fixture data
  KNOWN_SHOP = "regular-shop.myshopify.com"

  test "index redirects to login when the shop is not known" do
    unknown_shop = "other-shop.myshopify.com"

    get "/?shop=#{unknown_shop}"

    assert_redirected_to(%r{/api/auth\?shop=#{unknown_shop}})
  end

  test "index does not redirect if shop is installed but there is no online session" do
    User.delete_all

    get "/?shop=#{KNOWN_SHOP}"

    assert_response :success
    assert_match "text/html", @response.headers["Content-Type"]
  end

  test "index returns a 200 with HTML if a session exists" do
    get "/?shop=#{KNOWN_SHOP}"

    assert_response :success
    assert_match "text/html", @response.headers["Content-Type"]
  end

  test "falls back to returning the FE HTML if the URL doesn't match anything" do
    get "/random-url?shop=#{KNOWN_SHOP}"

    assert_response :success
    assert_match "text/html", @response.headers["Content-Type"]
  end
end
