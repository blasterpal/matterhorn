class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!

  add_env :current_user

  # used for inclusions
  allow_collection_params \
    :include

  allow_resource_params \
    :body, :title, author: [ :id ], topic: [:id, :name] 
end
