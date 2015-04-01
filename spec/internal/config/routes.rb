Rails.application.routes.draw do
  resources :posts do
    resources :comments
    resource :topic
    resource  :vote
  end
  # HACK nested singleton throws error in links generation, see:
  # https://github.com/blakechambers/matterhorn/issues/20#issuecomment-88976544
  resource  :topic

  resources :users
  resources :comments
end
