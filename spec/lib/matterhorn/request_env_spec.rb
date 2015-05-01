require 'spec_helper'

RSpec.describe "RequestEnv" do
  include SerialSpec

  let(:user) { User.make }

  def app
    PostsController.action(:index)
  end

  request_path        "/"
  request_method      "GET"
  request_envs.merge! "HTTP_ACCEPT" => "application/json"

  let(:url_options)  do
    {
      host:     "example.org",
      port:     nil,
      protocol: "http://",
      _recall:  {}
    }
  end

  let(:order_config) do
    Matterhorn::Ordering::OrderConfig.new(
      allowed_orders: {
        recent: [:created_at.desc],
        oldest: [:created_at.asc]
      },
      default_order: :recent
    )
  end

  let(:url_builder) { Matterhorn::Serialization::UrlBuilder.new(url_options: url_options) }

  let(:base_serialization_options) do
    {
      prefixes:          ["posts", "matterhorn/base"],
      template:          "index",
      url_options:       url_options,
      url_builder:       url_builder,
      request_env:       Matterhorn::RequestEnv.new(current_user: user, order_config: order_config, url_builder: url_builder, include_param: "", collection_params: {})
    }
  end

  let!(:post) { Post.make! }

  it "should pass a memoized hash of envs from the controller" do
    stub_serializer = class_double(ActiveModel::DefaultSerializer, :new)
    allow_any_instance_of(PostsController).to receive(:current_user).and_return(user)

    expect(PostSerializer).to receive(:new).once.with(post, base_serialization_options).and_call_original

    perform_request!
  end

end
