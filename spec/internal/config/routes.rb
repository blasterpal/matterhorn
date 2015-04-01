Rails.application.routes.draw do
  resources :posts do
    resource  :vote
    resources :comments
  end

  resources :users
  resources :comments
end
