require 'spec_helper'

RSpec.describe "create" do
  include ResourceHelpers
  include AuthenticationHelpers

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
    it_expects(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should create resource" do
      perform_request!
      it_should_create_resource(resource_class.first)
    end

  end
end

