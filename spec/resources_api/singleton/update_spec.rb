require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let(:existing_resource) {Topic.make!(post: existing_parent) }
  let(:existing_parent) { Post.make! } 
  let(:topic_name) { Faker::Lorem.word }
  let(:valid_params) do
    { 
      "#{resource_name}" =>
      {
        topic: 
        {
          name: topic_name
        }
      }
    }
  end

  let(:create_params) { valid_params } 

  with_request "PATCH /#{collection_name}/:id/topic.json"  do
    before do 
      request_params.merge!(create_params)
      request_path "/#{collection_name}/#{existing_parent.id}/topic.json"
    end
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should update resource" do
      perform_request!
      expected_resource = Topic.find_by(name: topic_name)

      it_should_respond_with_resource(expected_resource)
      it_expects_resource_key_to_match(:name, topic_name)
    end
    it "should not create another resource" do
      perform_request!
      actual = Topic.where(name: topic_name).to_a
      expect(actual.count).to eq(1)
    end
  end
end
