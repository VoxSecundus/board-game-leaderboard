Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  resources :players
  resources :games do
    collection { get :bgg_lookup }
  end
  resources :locations
  resources :plays

  get "compare", to: "comparisons#show", as: :compare

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
