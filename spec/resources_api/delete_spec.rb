require 'spec_helper'

RSpec.describe "delete" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post

  let(:existing_resource) { Post.make!(body: 'not nice body') } 
  
  with_request "DELETE /#{collection_name}/:id.json"  do
    before do 
      request_path "/#{collection_name}/#{existing_resource.id}.json"
    end
    its_status_should_be 204

    it "should delete resource" do
      perform_request!
      it_should_delete_resource(resource_class.first)
    end

  end
end

