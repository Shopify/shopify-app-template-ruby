# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  mount ShopifyApp::Engine, at: "/api"
  get "/api", to: redirect(path: "/") # Needed because our engine root is /api but that breaks FE routing

  # If you are adding routes outside of the /api path, remember to also add a proxy rule for
  # them in web/frontend/vite.config.js

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  scope path: :api, format: :json do
    # POST /api/products and GET /api/products/count
    resources :products, only: :create do
      collection do
        get :count
      end
    end
    namespace :shopify_webhooks do
      post "/app_uninstalled", to: "app_uninstalled#receive"
      post "/customers_data_request", to: "customers_data_request#receive"
      post "/customers_redact", to: "customers_redact#receive"
      post "/shop_redact", to: "shop_redact#receive"
    end
  end

  # Any other routes will just render the react app
  match "*path" => "home#index", via: [:get, :post]
end
