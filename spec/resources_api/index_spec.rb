require 'spec_helper'

RSpec.describe "index" do
  include ResourceHelpers

  collection_name "posts"
  resource_class Post
  resource_scope Post.all

  with_request "GET /#{collection_name}.json" do
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:collection_body) { expect(body[collection_name].execute).to be_an(Array) }

    it "should provide items with existing resources" do
      resource_class.make!

      perform_request!

      expect(body[collection_name].execute.count).to eq(1)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406

      # currently inherited_accessors cannot remove an item, so just overwrite
      # to prevent the expectation from firing.
      it_expects(:collection_body) { "do nothing" }
      it_expects(:error_body) { expect(body[:error].execute).to eq("ActionController::UnknownFormat") }

      perform_request!
    end

    it "should provide links object in response" do
      request_params.merge! include: "author"
      perform_request!
    end

    it "should list provided inclusions" do
      perform_request!

      # this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
      # expect(body[:links][:votes].execute).to eq("http://example.org/votes/{posts._id}")
      expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}")
    end

    context "when defining a custom scope" do
      let(:current_user)  { User.make!}
      let!(:users_votes)  { Vote.make!(user: current_user, post: existing_post) }
      let!(:other_votes)  { Vote.make! }
      let(:existing_post) { Post.make! }

      request_params.merge! include: "votes"

      it "should inclusions results" do
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
      end
    end

    # it "should provide meta object"
    # it "should return self link option"
    # it "should provide next"
  end
end