# frozen_string_literal: true

class AppUninstalledJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return
    end

    logger.info("#{self.class} started for shop '#{shop_domain}'")
    shop.destroy
  end
end
