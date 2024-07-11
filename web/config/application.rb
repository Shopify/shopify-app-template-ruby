# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShopifyAppTemplateRuby
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    config.assets.prefix = "/api/assets"

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ["assets", "tasks"])

    if ShopifyAPI::Context.embedded?
      config.action_dispatch.default_headers = config.action_dispatch.default_headers.merge({
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Headers" => "Authorization",
        "Access-Control-Expose-Headers" => "X-Shopify-API-Request-Failure-Reauthorize-Url",
      })
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
