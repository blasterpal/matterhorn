class PostsController < Matterhorn::Controller::Api
  include Matterhorn::Resources
  include Matterhorn::Inclusions::InclusionSupport

  resources!

  add_inclusion :votes do |config|

    config.scope do |controller|
      current_user.votes
    end
    require 'debugger'
    debugger
  end

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
