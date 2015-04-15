require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Post

  let(:existing_resource) { Topic.make!(post: existing_parent) }
  let(:existing_parent)   { Post.make! }
  let(:resource_params) do
    {
      topic: {
        name: "new name"
      }
    }
  end

  ie(:content_type)  { expect(headers["Content-Type"]).to include("application/json") }
  ie(:utf8)          { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:resource_body) { expect(body[top_level_key].execute).to be_a(Hash) }

  # TODO:
  # This is failing because of the misconfigured resource params here, the
  # resource should receive just a hash with topic as the parent, but its
  # currently nested under the parent resources name (i.e. posts/topics/name)
  #
  xit(:db_changed)    { expect(existing_resource.reload.name).to eq("new body") }

  its_status_should_be 200
  it_should_have_content_length

  with_request "PATCH /#{collection_name}/:id/topic.json"  do

    before do
      request_params.merge! resource_name => resource_params
      request_path "/#{collection_name}/#{existing_parent.id}/topic.json"
    end

  end
end
