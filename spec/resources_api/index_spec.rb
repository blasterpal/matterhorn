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

      errors = body[:errors]
      error  = errors.first

      expect(errors.execute.count).to eq(1)
      expect(error[:title].execute).to  eq("action_controller/unknown_format")
      expect(error[:detail].execute).to eq("ActionController::UnknownFormat")
      expect(error[:status].execute).to eq(406)
    end

    it "should provide complete links" do
      resource_class.make!
      perform_request!

    end

    context "when requesting inclusions" do

      let!(:users_vote) { Vote.make! user: current_user, post: post }
      let!(:other_vote) { Vote.make! post: post }
      let(:post)        { Post.make! }

      it "should included scoped votes" do
        request_params.merge! include: "votes"
        perform_request!

        expect(body[:includes]).to include_a_provided(users_vote)
      end

      pending "should include scoped authors" do
        request_params.merge! include: "author"
        perform_request!

        expect(body[:includes]).to include_a_provided(current_user)
      end

    end

    # it "should return self link option"
  end
end
