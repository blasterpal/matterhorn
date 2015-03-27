require 'spec_helper'

RSpec.describe "create" do
  include ResourceHelpers

  STUB_TOKEN = "authenticate"
  let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
  request_params.merge! auth_token: STUB_TOKEN

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  
  let(:post_body) { 'a nice body' }
  let(:create_params) do
    { 
      "#{resource_name}" =>
      {
        body: post_body
      }
    }
  end

  with_request "POST /#{collection_name}.json"  do
    before do 
      request_params.merge!(create_params)
    end
    its_status_should_be 201
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body) { expect(body[resource_name].execute).to be_a(Hash) }

    it "should create resource" do

      perform_request!
      expect(body).to provide(resource_class.first, as: PostSerializer, with_root: "post")
      expect(body[:post][:body].execute).to eq(post_body)

    end

  end
end

