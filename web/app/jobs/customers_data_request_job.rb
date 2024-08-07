# frozen_string_literal: true

class CustomersDataRequestJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return
    end

    shop.with_shopify_session do
      logger.info("#{self.class} started for shop '#{shop_domain}'")
    end
  end
end
