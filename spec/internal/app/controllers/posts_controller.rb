class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth
  include Matterhorn::Ordering

  allow_order :recent, :created_at.desc
  allow_order :oldest, :created_at.asc

  default_order :recent
  resources!

  add_env :current_user

  # used for inclusions
  allow_collection_params \
    :include

  allow_resource_params \
    :body, :title, author: [ :id ], topic: [:id, :name] 
end
