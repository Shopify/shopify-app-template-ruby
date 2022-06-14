# frozen_string_literal: true

class ProductsController < AuthenticatedController
  def count
    render(json: ShopifyAPI::Product.count.body)
  end
end
