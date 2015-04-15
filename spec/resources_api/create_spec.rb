require 'spec_helper'

RSpec.describe "create" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first

  let(:resource_params) { valid_params }
  let(:valid_params) do
    {
      body: "new body",
      title: "new title"
    }
  end

  its_status_should_be 201
  it_should_have_content_length

  it_expects(:content_type)  { expect(headers["Content-Type"]).to include("application/json") }
  it_expects(:utf8)          { expect(headers["Content-Type"]).to include("charset=utf-8") }
  it_expects(:resource_body) { expect(body[top_level_key].execute).to be_a(Hash) }
  it_expects(:db_changed)    { it_should_create_resource(resource_class.first) }

  with_request "POST /#{collection_name}.json"  do
    before do
      request_params.merge!(resource_name => resource_params)
    end

    it "should respond with Location header of new resource" do
      perform_request!
      created_resource = resource_class.first
      expect(headers["Location"]).to eq("http://example.org/#{collection_name}/#{created_resource.id}")
    end

    # TODO: relationship link testing should happen after 0.1.0
    # context "relationship links" do
    #   let(:nested_params) do
    #     {
    #       author: {
    #         id: current_user.id.to_s
    #       }
    #     }
    #   end
    #   let(:create_params) { valid_params.merge!(nested_params) }
    #   it "should create relationships" do
    #     perform_request!
    #     created_post_id = body[top_level_key][:_id].execute
    #     created_post    = Post.find(created_post_id)
    #     expect(body[top_level_key]).to provide(created_post)
    #   end
    # end

    context "errors" do
      let(:resource_params) do
        valid_params.merge(body: nil)
      end

      let(:errors) { body[:errors].execute }

      it "should return errors hash" do
        its_status_should_be 422

        it_expects(:resource_body)   { :do_nothing }
        it_expects(:db_changed)      { :do_nothing }

        perform_request!

        expect(errors.count).to eq(1)
        error_details = errors.collect {|ea| ea[:detail]}
        expected_errors = ["body: can't be blank" ]
        error_details.each do |error|
          expect(expected_errors).to include(error)
        end
      end

    end
  end
end
