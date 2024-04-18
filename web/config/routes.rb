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
  end

  # Any other routes will just render the react app
  match "*path" => "home#index", via: [:get, :post]
end
