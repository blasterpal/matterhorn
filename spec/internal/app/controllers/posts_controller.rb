class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  resources!

  add_inclusion :votes do |config|
    config.scope do |controller|
      controller.current_user.votes
    end
  end

  helper_method :current_user

  allow_collection_params \
    :include

protected ######################################################################

  def current_user
    User.first
  end

  def read_resource_scope
    Post.all
  end

  def write_resource_scope
    Post.all
  end

end
