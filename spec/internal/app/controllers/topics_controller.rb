class TopicsController < Matterhorn::Base
  include Matterhorn::Resource
  include FakeAuth

  resource!

  # :singleton => true #this causes resources_configuration[:post][:singleton] == true and breaks chain
  belongs_to :post

  add_env :current_user

  #allow_collection_params \
    #:include

protected ######################################################################
  #def begin_of_association_chain
    #@current_user
  #end

  def permitted_params
    params.require(:post).permit(:topic => [:id, :name])
  end

end
