# frozen_string_literal: true

require "test_helper"

class AppUninstalledJobTest < ActiveJob::TestCase
  test "that shop_domain in app_uninstalled is deleted from db" do
    shop_domain = "regular-shop.myshopify.com"

    shop = Shop.find_by(shopify_domain: shop_domain)
    assert_not_nil(shop)

    AppUninstalledJob.new.perform(topic: "app_uninstalled", shop_domain: shop_domain, webhook: {})

    shop = Shop.find_by(shopify_domain: shop_domain)
    assert_nil(shop)
  end
end
