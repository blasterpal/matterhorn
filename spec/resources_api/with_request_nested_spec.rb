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

  # causes 2 requests, one for with_request block 
  # where params are => {"auth_token"=>"authenticate", "controller"=>"votes", "action"=>"index", "post_id"=>":id", "format"=>"json"}
  # the post_id :id causes error
  xit "with_request nested url" do
    with_request "GET /#{collection_name}/:id/votes.json" do

      xit "should return nested resource scoped to parent" do
        request_method "GET"
        request_path "/#{collection_name}/#{post.id}/votes.json"
        perform_request!

        expect(body[top_level_key].execute).to provide(votes)
      end
    end
  end

end


