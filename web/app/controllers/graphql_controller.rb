# frozen_string_literal: true

class GraphqlController < AuthenticatedController
  def proxy
    response = ShopifyAPI::Utils::GraphqlProxy.proxy_query(
      headers: request.headers.to_h,
      body: request.body.read
    )

    render(json: response.body, status: response.code.to_i)
  rescue => e
    logger.info("Failed to run GraphQL proxy query: #{e.message}")
    render(json: "Failed to run GraphQL proxy query", status: 500)
  end
end
