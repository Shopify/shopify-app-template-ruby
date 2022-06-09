Rails.application.routes.draw do
  root :to => 'home#index'
  get '/products', :to => 'products#index'
  mount ShopifyApp::Engine, at: '/'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
