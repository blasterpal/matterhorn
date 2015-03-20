Rails.application.routes.draw do
  resources :posts do
    resource :vote
  end
  resources :users
  resources :votes
end
