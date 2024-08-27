# frozen_string_literal: true

ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.scope = ENV.fetch("SCOPES", "write_products") # See shopify.app.toml for scopes
  # Consult this page for more scope options: https://shopify.dev/api/usage/access-scopes
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = ShopifyAPI::AdminVersions::LATEST_SUPPORTED_ADMIN_VERSION

  # Offline Access Tokens Configuration
  # https://shopify.dev/docs/apps/build/authentication-authorization/access-token-types/offline-access-tokens
  config.shop_session_repository = "Shop"

  # Online Access Tokens Configuration
  # https://shopify.dev/docs/apps/build/authentication-authorization/access-token-types/online-access-tokens
  # Uncomment the following line to enable Online Access Tokens:
  # config.user_session_repository = "User"

  config.reauth_on_access_scope_changes = true
  config.new_embedded_auth_strategy = true

  config.root_url = "/api"
  config.login_url = "/api/auth"
  config.login_callback_url = "/api/auth/callback"
  config.embedded_redirect_url = "/ExitIframe"

  # You may want to charge merchants for using your app. Setting the billing configuration will cause the Authenticated
  # controller concern to check that the session is for a merchant that has an active one-time payment or subscription.
  # If no payment is found, it starts off the process and sends the merchant to a confirmation URL so that they can
  # approve the purchase.
  #
  # Learn more about billing in our documentation: https://shopify.dev/apps/billing
  # config.billing = ShopifyApp::BillingConfiguration.new(
  #   charge_name: "My app billing charge",
  #   amount: 5,
  #   interval: ShopifyApp::BillingConfiguration::INTERVAL_ANNUAL,
  #   currency_code: "USD", # Only supports USD for now
  # )

  config.api_key = ENV.fetch("SHOPIFY_API_KEY", "").presence
  config.secret = ENV.fetch("SHOPIFY_API_SECRET", "").presence
  # Set `old_secret` to the old secret when rotating client credentials
  # https://shopify.dev/docs/apps/build/authentication-authorization/client-secrets/rotate-revoke-client-credentials
  config.old_secret = ""
  config.myshopify_domain = ENV.fetch("SHOP_CUSTOM_DOMAIN", "").presence if ENV.fetch("SHOP_CUSTOM_DOMAIN", "").present?

  if defined? Rails::Server
    raise("Missing SHOPIFY_API_KEY. See https://github.com/Shopify/shopify_app#requirements") unless config.api_key
    raise("Missing SHOPIFY_API_SECRET. See https://github.com/Shopify/shopify_app#requirements") unless config.secret
  end
end

Rails.application.config.after_initialize do
  if ShopifyApp.configuration.api_key.present? && ShopifyApp.configuration.secret.present?
    ShopifyAPI::Context.setup(
      api_key: ShopifyApp.configuration.api_key,
      api_secret_key: ShopifyApp.configuration.secret,
      api_version: ShopifyApp.configuration.api_version,
      host_name: URI(ENV.fetch("HOST", "")).host || "",
      scope: ShopifyApp.configuration.scope,
      is_private: !ENV.fetch("SHOPIFY_APP_PRIVATE_SHOP", "").empty?,
      is_embedded: ShopifyApp.configuration.embedded_app,
      logger: Rails.logger,
      log_level: :info,
      private_shop: ENV.fetch("SHOPIFY_APP_PRIVATE_SHOP", nil),
      user_agent_prefix: "ShopifyApp/#{ShopifyApp::VERSION}",
      old_api_secret_key: ShopifyApp.configuration.old_secret,
    )
  end
end
