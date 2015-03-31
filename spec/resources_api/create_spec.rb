require 'spec_helper'

RSpec.describe "create" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  
  let(:post_body) { 'a nice body' }
  let(:author_id)    { current_user.id.to_s }

  let(:create_params) do
    { 
      "#{resource_name}" =>
      {
        body: post_body,
        title: 'A cool title!',
        author: 
          {id: author_id }
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

    context "errors" do
      let(:post_body) { nil }
      let(:author_id) { nil }
      let(:errors) { body[:errors].execute } 
        it "should return errors hash" do
          its_status_should_be 422
          it_expects(:resource_body)   { 'nada' } #nix the previous it_expects^
          
          perform_request!
          expect(errors.size).to eq(2)
          error_details = errors.collect {|ea| ea[:detail]}
          expected_errors = ["author: can't be blank", "body: can't be blank" ]
          error_details.each do |error|
            expect(expected_errors).to include(error)
          end
        end
    end

  end

end

