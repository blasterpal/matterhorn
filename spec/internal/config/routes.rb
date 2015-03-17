Rails.application.routes.draw do
  resources :posts
  resources :users
  resources :votes
end