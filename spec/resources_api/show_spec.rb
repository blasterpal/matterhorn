require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  let(:resource) { resource_class.make! initial_comments_ids: [1,2,3] }

  with_request "GET /#{collection_name}/:id.json" do
    request_path { "/#{collection_name}/#{resource.id}.json" } 

    its_status_should_be 200
    it_should_have_content_length

    ie(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    ie(:resource_body)   { expect(body[top_level_key].execute).to be_a(Hash) }

    it "should provide item with existing resources" do
      perform_request!
      it_should_have_top_level_data_for_resource
      it_should_respond_with_resource
    end

    it "should provide links object in response" do
      request_params.merge! include: "author"
      perform_request!

      expect(body[:links].execute).to be_kind_of(Hash)
      expect(body[:links].execute).to be_kind_of(Hash)
    end

    it "should list provided inclusions" do
      perform_request!

      expect(body[:links][:votes].execute).to eq("http://example.org/posts/{posts._id}/vote")
      expect(body[:links][:author].execute).to eq("http://example.org/users/{posts.author_id}")
    end

    context "when defining a custom scope" do

      let!(:users_votes)  { Vote.make! user: current_user, post: resource }
      let!(:other_votes)  { Vote.make! post: resource }

      # this is broken because of the current_user testing strategy 'User.first'
      it "should included scoped votes" do
        request_params.merge! include: "votes"
        perform_request!
        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:_id].execute).to eq(users_votes.id.to_s)
      end

      # this is broken because of the current_user testing strategy 'User.first'
      it "should include scoped authors" do
        request_params.merge! include: "author"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:_id].execute).to eq(resource.author_id.to_s)
      end

      it "should provide complete links" do
        perform_request!

        # this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
        expect(body[:data][:links][:votes].execute).to eq({"linkage"=>{"id"=> resource.id.to_s, "type"=>"votes"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/vote"})
        expect(body[:data][:links][:author].execute).to eq({"linkage"=>{"id"=>resource.author_id.to_s, "type"=>"users"}, "related"=>"http://example.org/users/#{resource.author_id.to_s}"})
        expect(body[:data][:links][:initial_comments].execute).to eq({"linkage"=>{"id"=>"1,2,3", "type"=>"comments"}, "related"=>"http://example.org/comments/1,2,3"})
        expect(body[:data][:links][:comments].execute).to eq({"linkage"=>{"id"=> resource.id.to_s, "type"=>"comments"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/comments"})
      end

    end

    context "with no author" do
      let(:resource) { resource_class.make! author: nil, initial_comments_ids: [1,2,3] }
      it "should not return the author link if the author id is not in the response" do
        perform_request!
        expect(body[:data][:author_id].execute).to be_nil
        expect(body[:data][:links][:author].execute).to be_nil
      end

    end
    # it "should provide meta object"
    # it "should return self link option"
    # it "should provide next"
  end
end
