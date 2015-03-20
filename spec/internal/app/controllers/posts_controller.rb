class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  resources!

  scope = proc do |set_member|
    current_user.votes
  end

  add_inclusion :votes, scope: scope

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
