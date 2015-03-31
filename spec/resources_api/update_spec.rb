require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let(:existing_resource) { Post.make!(body: 'not nice body') } 
  
  let(:post_body) { 'a nice body' }
  let(:post_title)    { 'even nicer title' }

  
  let(:valid_params) do
    { 
      "#{resource_name}" =>
      {
        body: post_body,
        title: post_title
      }
    }
  end
  let(:create_params) { valid_params } 

  with_request "PATCH /#{collection_name}/:id.json"  do
    before do 
      request_params.merge!(create_params)
      request_path "/#{collection_name}/#{existing_resource.id}.json"
    end
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should update resource" do
      perform_request!
      it_should_respond_with_resource(resource_class.first)
      it_expects_resource_key_to_match(:body, post_body)
    end
    it "should not create another resource" do
      perform_request!
      posts = Post.where(title: post_title).to_a
      expect(posts.size).to eq(1)
    end
  end

  with_request "PUT /#{collection_name}/:id.json"  do
    before do 
      request_params.merge!(create_params)
      request_path "/#{collection_name}/#{existing_resource.id}.json"
    end
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should update resource" do
      perform_request!
      it_should_respond_with_resource(resource_class.first)
      it_expects_resource_key_to_match(:body, post_body)
    end

  end

end

