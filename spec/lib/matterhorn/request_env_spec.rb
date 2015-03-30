require 'spec_helper'

RSpec.describe "RequestEnv" do
  include ClassBuilder
  include SerialSpec

  let(:user) { User.make }

  def app
    PostsController.action(:index)
  end

  request_path        "/"
  request_method      "GET"
  request_envs.merge! "HTTP_ACCEPT" => "application/json"

  let(:base_serialization_options) do
    {
      :prefixes =>  ["posts", "matterhorn/base"],
      :template => "index",
      :url_options => {
        :host => "example.org",
        :port => nil,
        :protocol => "http://",
        :_recall => {}
      },
      :collection_params => {},
      :controller_inclusions => Matterhorn::Inclusions::InclusionSet.new({})
    }
  end

  let!(:post) { Post.make! }

  it "should pass a memoized hash of envs from the controller" do
    stub_serializer = class_double(ActiveModel::DefaultSerializer, :new)
    allow_any_instance_of(PostsController).to receive(:current_user).and_return(user)

    request_env = Matterhorn::RequestEnv.new(current_user: user)

    expected_options = base_serialization_options.merge(request_env: request_env)
    expect(PostSerializer).to receive(:new).once.with(post, expected_options).and_call_original

    perform_request!
  end

end
