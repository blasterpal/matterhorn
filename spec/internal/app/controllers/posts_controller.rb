class PostsController < Matterhorn::Controller::Api
  include Matterhorn::Resources

  resources!

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
