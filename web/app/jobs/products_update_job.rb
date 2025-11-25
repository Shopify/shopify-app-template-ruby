# frozen_string_literal: true

class ProductsUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return
    end

    logger.info("#{self.class} started for shop '#{shop_domain}'")

    # Process the product update webhook
    product_id = webhook["id"]
    product_gid = "gid://shopify/Product/#{product_id}"

    logger.info("Product updated: ID=#{product_id}")

    # Query product data using GraphQL
    shop.with_shopify_session do |session|
      client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

      query = <<~QUERY
        query getProduct($id: ID!) {
          product(id: $id) {
            id
            title
            handle
            status
            vendor
            productType
            tags
            totalInventory
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  price
                  sku
                  inventoryQuantity
                }
              }
            }
          }
        }
      QUERY

      response = client.query(query: query, variables: { id: product_gid })

      if response.body["errors"]
        logger.error("GraphQL query failed: #{response.body["errors"]}")
        return
      end

      product_data = response.body.dig("data", "product")

      if product_data
        logger.info("Product Data: #{product_data.to_json}")
        logger.info("Title: #{product_data["title"]}")
        logger.info("Status: #{product_data["status"]}")
        logger.info("Total Inventory: #{product_data["totalInventory"]}")
        logger.info("Variants Count: #{product_data.dig("variants", "edges")&.length || 0}")

        # Add your business logic here
        # For example:
        # - Update local database records
        # - Sync with other systems
        # - Send notifications
        # - Update inventory
      else
        logger.warn("Product not found: #{product_gid}")
      end
    end
  rescue StandardError => e
    logger.error("#{self.class} failed: #{e.message}")
    logger.error(e.backtrace.join("\n"))
    raise
  end
end
