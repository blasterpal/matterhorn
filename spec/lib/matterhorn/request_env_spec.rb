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

  let(:pagination) { Matterhorn::Paging::Default.new(post, request_env) }

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

  let(:request_env){ Matterhorn::RequestEnv.new(include_param: "",
                                                current_user: user, 
                                                url_builder: url_builder,   
                                                collection_params: {}) }

  let(:base_serialization_options) do
    {
      prefixes:          ["posts", "matterhorn/base"],
      template:          "index",
      url_options:       url_options,
      url_builder:       url_builder,
      pagination:        pagination,
      order_config:      order_config,
      request_env:       request_env
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
