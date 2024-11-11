# frozen_string_literal: true

class ProductCounter < ApplicationService
  include ShopifyApp::AdminAPI::WithTokenRefetch

  GET_PRODUCT_COUNT_QUERY = <<~QUERY
    query countProducts {
      productsCount {
        count
      }
    }
  QUERY

  def initialize(session:, id_token:)
    super
    @session = session
    @id_token = id_token
  end

  def call
    response = with_token_refetch(@session, @id_token) do
      client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
      client.query(query: GET_PRODUCT_COUNT_QUERY)
    end

    raise StandardError, response.body["errors"].to_s if response.body["errors"]

    response.body.dig("data", "productsCount")
  end
end
