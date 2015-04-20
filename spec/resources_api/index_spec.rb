require 'spec_helper'

RSpec.describe "index" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_class Post
  resource_scope Post.all

  # NOTE helpers presume presence of either collection or resource variables
  let(:collection) { resource_scope.to_a }

  its_status_should_be 200
  it_should_have_content_length

  ie(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
  ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:collection_body) { expect(data.execute).to be_an(Array) }
  ie(:link_vote)       { expect(body[:links][:votes].execute).to eq("http://example.org/posts/{posts._id}/vote") }
  ie(:link_author)     { expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}") }
  ie(:link_comments)   { expect(body[:links][:initial_comments].execute).to eq("http://example.org/comments/{posts.initial_comments_ids}") }

  with_request "GET /#{collection_name}.json" do

    it "should provide items with existing resources" do
      resource_class.make!
      perform_request!

      it_should_have_top_level_data_for_collection
      expect(data.execute.count).to eq(1)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406
      ie(:collection_body) { "do nothing" }
      ie(:link_vote)       { "do nothing" }
      ie(:link_author)     { "do nothing" }
      ie(:link_comments)   { "do nothing" }

      perform_request!

      expect(body[:errors].execute.count).to eq(1)
      expect(body[:errors].first[:title].execute).to  eq("action_controller/unknown_format")
      expect(body[:errors].first[:detail].execute).to eq("ActionController::UnknownFormat")
      expect(body[:errors].first[:status].execute).to eq(406)
    end

    it "should provide complete links" do
      resource_class.make!
      perform_request!
    end

    it "when requesting inclusions" do
      pending "expect(body[:includes].first.execute).to provide(post) currently fails to provide an actual serialized object, but instead seems to call to_json on the object."

      let!(:users_vote) { Vote.make! user: current_user, post: post }
      let!(:other_vote) { Vote.make! post: post }
      let(:post)        { Post.make! }

      xit "should included scoped votes" do
        request_params.merge! include: "votes"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first.execute).to provide(users_vote)
      end

      xit "should include scoped authors" do
        request_params.merge! include: "author"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first.execute).to provide(post)
      end

    end

    # it "should provide meta object"
    # it "should return self link option"
    # it "should provide next"
  end
end
