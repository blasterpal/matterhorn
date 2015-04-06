class TopicsController < Matterhorn::Base
  include Matterhorn::Resource
  include FakeAuth

  resource!

  # :singleton => true #this causes resources_configuration[:post][:singleton] == true and breaks chain
  belongs_to :post

  add_env :current_user

  allow_resource_params \
    :id, :name
  
end
