require 'spec_helper'

RSpec.describe "delete" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Post

  request_path { "/#{collection_name}/#{existing_resource.id}.json" }

  let(:existing_resource) { Post.make! }

  its_status_should_be 204
  ie(:db_changed) { it_should_delete_resource(resource_class.first) }

  context "resources!" do
    with_request "DELETE /#{collection_name}/:id.json"
  end

  context "resource!" do
    # resource_name   "topic"
    resource_class  Topic

    request_path {"/#{collection_name}/#{existing_parent.id}/topic.json" }

    let(:existing_parent) { Post.make! }
    let(:existing_resource) { existing_parent.topic }

    with_request "DELETE /#{collection_name}/:id/topic.json"
  end

end
