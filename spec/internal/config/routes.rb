Rails.application.routes.draw do
  resources :posts do
    resources :comments
    resource  :topic
    resource  :vote, path: :my_vote
  end
  resources :users
  resources :comments
end
