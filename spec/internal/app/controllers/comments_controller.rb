class CommentsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!
  belongs_to :post

  add_env :current_user

  allow_collection_params \
    :include

protected ######################################################################

  #def begin_of_association_chain
    #current_user
  #end

  #def read_resource_scope
    #end_of_association_chain
  #end

  #def write_resource_scope
    #end_of_association_chain
  #end

end
