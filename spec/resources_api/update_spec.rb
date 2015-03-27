require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers

  STUB_TOKEN = "authenticate"
  let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
  request_params.merge! auth_token: STUB_TOKEN

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let(:existing_resource) { Post.make!(body: 'not nice body') } 
  
  let(:post_body) { 'a nice body2' }
  let(:create_params) do
    { 
      "#{resource_name}" =>
      {
        body: post_body
      }
    }
  end

  with_request "PATCH /#{collection_name}/:id.json"  do
    before do 
      request_params.merge!(create_params)
      request_path "/#{collection_name}/#{existing_resource.id}.json"
    end
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body) { expect(body[resource_name].execute).to be_a(Hash) }

    it "should update resource" do

      perform_request!
      expect(body).to provide(resource_class.first, as: PostSerializer, with_root: "post")
      expect(body[:post][:body].execute).to eq(post_body)

    end

  end
end

