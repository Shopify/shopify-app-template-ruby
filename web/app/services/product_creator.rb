# frozen_string_literal: true

class ProductCreator < ApplicationService
  include ShopifyApp::AdminAPI::WithTokenRefetch

  attr_reader :count

  CREATE_PRODUCTS_MUTATION = <<~QUERY
    mutation populateProduct($title: String!) {
      productCreate(input: {title: $title}) {
        product {
          title
          id
        }
      }
    }
  QUERY

  def initialize(count:, session:, id_token:)
    super
    @count = count
    @session = session
    @id_token = id_token
  end

  def call
    count.times do
      response = with_token_refetch(@session, @id_token) do
        client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
        client.query(query: CREATE_PRODUCTS_MUTATION, variables: { title: random_title })
      end

      raise StandardError, response.body["errors"].to_s if response.body["errors"]

      created_product = response.body.dig("data", "productCreate", "product")
      Rails.logger.info("Created Product | Title: '#{created_product["title"]}' | Id: '#{created_product["id"]}'")
    end
  end

  private

  def random_title
    "#{ADJECTIVES.sample} #{NOUNS.sample}"
  end

  ADJECTIVES = [
    "autumn",
    "hidden",
    "bitter",
    "misty",
    "silent",
    "empty",
    "dry",
    "dark",
    "summer",
    "icy",
    "delicate",
    "quiet",
    "white",
    "cool",
    "spring",
    "winter",
    "patient",
    "twilight",
    "dawn",
    "crimson",
    "wispy",
    "weathered",
    "blue",
    "billowing",
    "broken",
    "cold",
    "damp",
    "falling",
    "frosty",
    "green",
    "long",
  ]

  NOUNS = [
    "waterfall",
    "river",
    "breeze",
    "moon",
    "rain",
    "wind",
    "sea",
    "morning",
    "snow",
    "lake",
    "sunset",
    "pine",
    "shadow",
    "leaf",
    "dawn",
    "glitter",
    "forest",
    "hill",
    "cloud",
    "meadow",
    "sun",
    "glade",
    "bird",
    "brook",
    "butterfly",
    "bush",
    "dew",
    "dust",
    "field",
    "fire",
    "flower",
  ]
end
