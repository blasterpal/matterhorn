require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first

  let!(:users_comments)  { Comment.make! user: current_user, post: post }
  let!(:other_comments)  { Comment.make! post: post }
  let(:post)          { Post.make! }
  let(:comments)         { Comment.where(post: post) }

  context 'with_request "GET /#{collection_name}/:id/comments.json"' do

    its_status_should_be 200
    it_should_have_content_length

    ie(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    ie(:collection_body) { expect(body[top_level_key].execute).to be_an(Array) }

    # TODO: Using provide here doesn't take into account links.  Marking it as skipped
    # for now
    xit "should return nested resource scoped to parent" do
      request_method "GET"
      request_path "/#{collection_name}/#{post.id}/comments.json"
      perform_request!

      expect(data).to provide(comments)
    end
  end

end
