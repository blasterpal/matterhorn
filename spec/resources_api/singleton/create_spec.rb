require 'spec_helper'

RSpec.describe "create singleton" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let!(:post)          { Post.make!(topic:nil) }

  let(:topic_name) { 'Flimflam' }

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
  with_request "POST /#{collection_name}/:id/topic.json"  do
    before do 
      request_params.merge!(create_params)
      request_path "/#{collection_name}/#{post.id}/topic.json"
    end
    its_status_should_be 201
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should create resource" do
      perform_request!
      expected = Topic.find_by(name: topic_name )
      it_should_create_resource(expected)
    end

    it "should respond with Location header of new resource" do
      perform_request!
      created_resource = resource_class.first
      expect(headers["Location"]).to eq("http://example.org/#{collection_name}/#{created_resource.id}/topic")
    end

    context "errors" do
      let(:topic_name) { nil }
      let(:errors) { body[:errors].execute } 
      it "should return errors hash" do
        its_status_should_be 422
        it_expects(:resource_body)   { 'nada' } #nix the previous it_expects^

        perform_request!
        expect(errors.size).to eq(1)
        error_details = errors.collect {|ea| ea[:detail]}
        expected_errors = ["name: can't be blank"]
        error_details.each do |error|
          expect(expected_errors).to include(error)
        end
      end

    end
  end
end

