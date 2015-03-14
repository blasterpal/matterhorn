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
    it_expects(:collection_body) { expect(body[collection_name]).to be_an(Array) }

    it "should provide items with existing resources" do
      resource_class.make!

      perform_request!

      expect(body[collection_name].count).to eq(1)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406

      # currently inherited_accessors cannot remove an item, so just overwrite
      # to prevent the expectation from firing.
      it_expects(:collection_body) { "do nothing" }
      it_expects(:error_body) { expect(body["error"]).to eq("ActionController::UnknownFormat") }

      perform_request!
    end

    it "should provide links object in response" do
      request_params.merge! include: "author"
      perform_request!

    end

    it "should provide meta object"
    it "should list provided inclusions" do
      perform_request!

      expect(body["links"]).to include({"author" => "http://example.org/users/{posts.author_id}"})
    end

    it "should return self link option"
    it "should provide next"
  end
end