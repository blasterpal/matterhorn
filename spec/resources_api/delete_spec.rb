require 'spec_helper'

RSpec.describe "delete" do
  include ResourceHelpers

  STUB_TOKEN = "authenticate"
  let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
  request_params.merge! auth_token: STUB_TOKEN

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
      expect(response.body).to be_empty
      expect(Post.where(id:existing_resource.id).first).to be_nil

    end

  end
end

