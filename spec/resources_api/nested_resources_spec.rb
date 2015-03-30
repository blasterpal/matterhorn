require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first

  let!(:users_votes)  { Vote.make! user: current_user, post: post }
  let!(:other_votes)  { Vote.make! post: post }
  let(:post)          { Post.make! }
  let(:votes)         { Vote.where(post: post) }

  context 'with_request "GET /#{collection_name}/:id/votes.json"' do
    
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:collection_body) { expect(body[top_level_key].execute).to be_an(Array) }

    it "should return nested resource scoped to parent" do
      request_method "GET"
      request_path "/#{collection_name}/#{post.id}/votes.json"
      perform_request!

      expect(body[top_level_key].execute).to provide(votes)
    end
  end

end

