require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first

  let!(:users_vote)  { Vote.make! user: current_user, post: post }
  let!(:other_vote)  { Vote.make! post: post }
  let(:post)         { Post.make! }

  request_method "GET"

  it "should return nested resource scoped to parent" do
    request_path "/#{collection_name}/#{post.id}/vote.json"

    perform_request!

    expect(body[top_level_key].execute).to provide(users_vote)
  end

end
