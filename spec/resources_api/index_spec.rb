require 'spec_helper'

RSpec.describe "index" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"  
  resource_class Post
  resource_scope Post.all

  # NOTE helpers presume presence of either collection or resource variables

  let(:collection) { resource_scope.to_a }

  with_request "GET /#{collection_name}.json" do

    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:collection_body) { expect(body[top_level_key].execute).to be_an(Array) }


    it "should provide items with existing resources" do
      resource_class.make!
      perform_request!

      it_should_have_top_level_data_for_collection
      it_should_respond_with_collection
      expect(body[top_level_key].execute.count).to eq(1)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406

      # currently inherited_accessors cannot remove an item, so just overwrite
      # to prevent the expectation from firing.
      error_payload = {
        errors: [
          {
            title: "action_controller/unknown_format",
            detail: "ActionController::UnknownFormat",
            status: 406
          }
        ]
      }.deep_stringify_keys
            
      it_expects(:collection_body) { "do nothing" }
      it_expects(:error_body) { expect(body.execute).to eq(error_payload) }

      perform_request!
    end

    it "should provide links object in response" do
      request_params.merge! include: "author"
      perform_request!

      expect(body[:links].execute).to be_kind_of(Hash)
    end

    it "should list provided links" do
      perform_request!

      # this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
      expect(body[:links][:votes].execute).to eq("http://example.org/posts/{posts._id}/vote")
      expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}")
      expect(body[:links][:initial_comments].execute).to eq("http://example.org/comments/{posts.initial_comments_ids}")
    end

    it "should provide complete links" do
      resource_class.make!
      perform_request!

      # this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
      expect(body[:links][:votes].execute).to eq("http://example.org/posts/{posts._id}/vote")
      expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}")
      expect(body[:links][:initial_comments].execute).to eq("http://example.org/comments/{posts.initial_comments_ids}")
    end

    context "when defining a custom scope" do

      let!(:users_votes)  { Vote.make! user: current_user, post: post }
      let!(:other_votes)  { Vote.make! post: post }
      let(:post) { Post.make! }

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
        expect(body[:includes].first[:_id].execute).to eq(post.author_id.to_s)
      end

    end

      # it "should provide meta object"
      # it "should return self link option"
      # it "should provide next"
  end
end
