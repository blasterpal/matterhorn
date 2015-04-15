class VotesController < Matterhorn::Base
  include Matterhorn::Resource
  include FakeAuth

  resource!
  belongs_to :post

  add_env :current_user

protected ######################################################################

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.send(:votes).find_by(user: current_user))
  end

end
