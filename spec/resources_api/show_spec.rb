require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers

  STUB_TOKEN = "authenticate"
  let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
  request_params.merge! auth_token: STUB_TOKEN

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  let(:resource) { resource_class.make! } 
  
  with_request "GET /#{collection_name}/:id.json" do
    before { request_path "/#{collection_name}/#{resource.id}.json" } 

    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:resource_body)   { expect(body[resource_name].execute).to be_a(Hash) }

    it "should provide item with existing resources" do
      perform_request!
      expect(body).to provide(resource, as: PostSerializer, with_root: resource_name)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}/#{resource.id}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406

      # currently inherited_accessors cannot remove an item, so just overwrite
      # to prevent the expectation from firing.
      it_expects(:resource_body) { "do nothing" }
      it_expects(:error_body) { expect(body[:error].execute).to eq("ActionController::UnknownFormat") }

      perform_request!
    end

    it "should provide links object in response" do
      request_params.merge! include: "author"
      perform_request!

      expect(body[:links].execute).to be_kind_of(Hash)
      expect(body[:links].execute).to be_kind_of(Hash)
    end

    it "should list provided inclusions" do
      perform_request!

      # this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
      expect(body[:links][:votes].execute).to eq("http://example.org/posts/{posts._id}/votes")
      expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}")
    end

    context "when defining a custom scope" do

      let!(:users_votes)  { Vote.make! user: current_user, post: resource }
      let!(:other_votes)  { Vote.make! post: resource }

      # this is broken because of the current_user testing strategy 'User.first'
      it "should included scoped votes" do
        request_params.merge! include: "votes"
        perform_request!
        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:_id].execute).to eq(users_votes.id.to_s)
      end

      # this is broken because of the current_user testing strategy 'User.first'
      it "should include scoped authors" do
        request_params.merge! include: "author"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:_id].execute).to eq(resource.author_id.to_s)
      end
    end

    # it "should provide meta object"
    # it "should return self link option"
    # it "should provide next"

  end
end
