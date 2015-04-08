require 'spec_helper'

RSpec.describe "reject links" do
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
  let(:valid_params) do 
    {
      "#{resource_name}" =>
      {
        body: 'body1',
        title: "post_title"
      }
    }
  end

  context "links in resource url" do
    with_request "GET /#{collection_name}/links.json" do
      before do 
        request_params.merge!(valid_params)
      end
      it "should return 403" do
        perform_request!
        its_status_should_be 403
      end
    end
  end

  context "links deeply nested in resource url" do
    with_request "GET /#{collection_name}/:id/links.json" do
      before do 
        request_path "/#{collection_name}/#{post.id}/links.json"
        request_params.merge!(valid_params)
      end
      it "should return 403" do
        perform_request!
        its_status_should_be 403
      end
    end
  end

  context "top level links" do
    let(:top_level_links) do 
      { 
        links: { 
          author: {
            linkage: {
              type:"user",id:"9"
            }
          }
        }
      }
    end

    with_request "POST /#{collection_name}.json" do
      before do
        request_params.merge!(top_level_links)
      end
      it "should return 403" do
        perform_request!
        its_status_should_be 403
      end
    end
  end

  context "links attributes within resource attributes" do
    let(:invalid_params) do
      {
        "#{resource_name}" =>
        {
          body: 'body1',
          title: "post_title",
          links: {
            author: {
              linkage: {
                type:"user",id:"9"
              }
            }          
          }
        }
      }
    end
    with_request "POST /#{collection_name}.json" do
      before do
        request_params.merge!(invalid_params)
      end
      it "should return 403" do
        perform_request!
        its_status_should_be 403
      end
    end
  end
end
