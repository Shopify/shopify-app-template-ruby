# frozen_string_literal: true

class GraphqlController < AuthenticatedController
  def proxy
    response = ShopifyAPI::Utils::GraphqlProxy.proxy_query(
      headers: request.headers.to_h,
      body: request.body.read
    )

    render(json: response.body, status: response.code.to_i)
  rescue => e
    message = "Failed to run GraphQL proxy query: #{e.message}"

    code = e.is_a?(ShopifyAPI::Errors::HttpResponseError) ? e.code : 500

    logger.info(message)
    render(json: message, status: code)
  end
end
