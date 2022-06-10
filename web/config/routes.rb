# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  mount ShopifyApp::Engine, at: "/api"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Any other routes will just render the react app
  match "*path" => "home#index", via: [:get, :post]
end
