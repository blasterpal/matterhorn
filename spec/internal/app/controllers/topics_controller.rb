class TopicsController < Matterhorn::Base
  include Matterhorn::Resource
  include FakeAuth

  resource!
  belongs_to :post

  add_env :current_user

  allow_resource_params \
    :id, :name

end
