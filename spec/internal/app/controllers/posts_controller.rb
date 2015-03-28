class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!

  add_env :current_user

  allow_collection_params \
    :include

  allow_write_params \
    :body


protected ######################################################################
  
end
