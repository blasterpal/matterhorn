class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!

  add_env :current_user

  allow_collection_params \
    :include

protected ######################################################################

  def read_resource_scope
    Post.all
  end

  def write_resource_scope
    Post.all
  end

end
