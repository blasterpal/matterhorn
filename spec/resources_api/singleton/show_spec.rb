require "spec_helper"

describe "show singleton" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let!(:post)          { Post.make! }
  let!(:topic)         { post.topic }
  
  context 'with_request "GET /#{collection_name}/:id/topic.json"' do
    
    its_status_should_be 200
    it_should_have_content_length

    it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    it_expects(:collection_body) { expect(body[top_level_key].execute).to be_an(Hash) }

    it "should return nested resource scoped to parent" do
      request_method "GET"
      request_path "/#{collection_name}/#{post.id}/topic.json"
      perform_request!

      expect(body[top_level_key].execute).to provide(topic)
    end
  end

end
