class AuthorsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!
  belongs_to :post

  allow_collection_params \
    :include

protected ######################################################################
    
  def resource
    User
  end
end
