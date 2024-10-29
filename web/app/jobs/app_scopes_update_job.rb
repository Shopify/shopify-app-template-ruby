# frozen_string_literal: true

class AppScopesUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    logger.info("#{self.class} started for shop '#{shop_domain}'")
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return
    end

    shop.access_scopes = webhook["current"].join(",")
    shop.save!
  end
end
