class VotesController < Matterhorn::Base
  include Matterhorn::Resources
  resources!

  allow_collection_params \
    :include

protected ######################################################################

  def read_resource_scope
    current_user.votes.all
  end

  def write_resource_scope
    current_user.votes.all
  end

end
