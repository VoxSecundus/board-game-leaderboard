Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  resources :players
  resources :games do
    collection do
      get  :bgg_lookup
      get  :bgg_import
      post :bgg_import
    end
  end
  resources :locations
  resources :plays do
    collection do
      get  :bulk_new
      post :bulk_create
    end
  end

  get "compare", to: "comparisons#show", as: :compare

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
