class MigrateShopsToExpiringTokensJob < ActiveJob::Base
  queue_as :default

  def perform
    # Find shops that haven't been migrated yet (no refresh_token or expires_at)
    shops_to_migrate = Shop.where(expires_at: nil, refresh_token: nil, refresh_token_expires_at: nil)

    shops_to_migrate.find_each do |shop|
      begin
        # Migrate to expiring token
        new_session = ShopifyAPI::Auth::TokenExchange.migrate_to_expiring_token(
          shop: shop.shopify_domain,
          non_expiring_offline_token: shop.shopify_token
        )

        # Store the new session with expiring token and refresh token
        Shop.store(new_session)

        Rails.logger.info("Successfully migrated #{shop.shopify_domain} to expiring token")
      rescue ShopifyAPI::Errors::HttpResponseError => e
        # Handle migration errors (e.g., shop uninstalled, network issues)
        Rails.logger.error("Failed to migrate #{shop.shopify_domain}: #{e.message}")
      rescue => e
        Rails.logger.error("Unexpected error migrating #{shop.shopify_domain}: #{e.message}")
      end
    end
  end
end

