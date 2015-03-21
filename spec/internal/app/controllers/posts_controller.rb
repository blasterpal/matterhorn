class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!

  scope = proc do |set_member|
    current_user.votes.all
  end

  add_inclusion :votes, scope: scope

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
