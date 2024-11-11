# frozen_string_literal: true

class ProductsController < AuthenticatedController
  # GET /api/products/count
  def count
    product_count = ProductCounter.call(session: current_shopify_session, id_token: shopify_id_token)
    ShopifyAPI::Logger.info("Retrieved product count: #{product_count["count"]}")
    render(json: product_count)
  rescue StandardError => e
    logger.error("Failed to retrieve product count: #{e.message}")
    render(json: { success: false, error: e.message }, status: e.try(:code) || :internal_server_error)
  end

  # POST /api/products
  def create
    ProductCreator.call(count: 5, session: current_shopify_session, id_token: shopify_id_token)
    render(json: { success: true, error: nil })
  rescue StandardError => e
    logger.error("Failed to create products: #{e.message}")
    render(json: { success: false, error: e.message }, status: e.try(:code) || :internal_server_error)
  end
end
