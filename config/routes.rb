Rails.application.routes.draw do
  resources :airplane_seats, only: [:index, :create]
  root 'airplane_seats#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
