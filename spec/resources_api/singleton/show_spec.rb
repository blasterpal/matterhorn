require "spec_helper"

describe "show singleton" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Post
  resource_scope  Post.first

  request_path { "/#{collection_name}/#{post.id}/vote.json" }

  let!(:users_vote) { Vote.make! user: current_user, post: post }
  let!(:other_vote) { Vote.make! post: post }
  let(:post)        { Post.make! }

  ie(:data)       { expect(data).to provide(users_vote) }
  ie(:links_self) { expect(data[:links][:self].execute).to eq("http://example.org/posts/#{post.id}/vote") }

  with_request "GET /:collection_name/:id/vote"
end
