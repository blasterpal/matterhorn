require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Post

  let!(:path)   { request_path "/#{collection_name}/#{existing_resource.id}.json" }
  let!(:params) { request_params.merge! resource_name => resource_params }

  let(:existing_resource) { Post.make!(body: "body") }

  let(:resource_params) do
    {
      body: "new body"
    }
  end

  its_status_should_be 200
  it_should_have_content_length

  ie(:content_type)  { expect(headers["Content-Type"]).to include("application/json") }
  ie(:utf8)          { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:resource_body) { expect(body[top_level_key].execute).to be_a(Hash) }
  ie(:db_changed)    { expect(existing_resource.reload.body).to eq("new body") }

  with_request "PATCH /#{collection_name}/:id.json" do

    context "with PUT" do
      request_method "PUT"

      it "should accept PUT" do
        perform_request!
      end
    end
  end

end
