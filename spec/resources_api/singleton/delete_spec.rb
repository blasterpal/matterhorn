require 'spec_helper'

RSpec.describe "delete singleton" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Topic

  let!(:path)           { request_path "/#{collection_name}/#{existing_parent.id}/topic.json" }
  let(:existing_parent) { Post.make! }
  let(:existing_resource) { existing_parent.topic }

  its_status_should_be 204
  ie(:db_changed) { it_should_delete_resource(resource_class.first) }

  with_request "DELETE /#{collection_name}/:id.json"
end
