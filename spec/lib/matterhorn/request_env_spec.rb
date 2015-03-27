require 'spec_helper'

RSpec.describe "RequestEnv" do
  include ClassBuilder
  include SerialSpec

  let(:user) { User.make }

  # let(:article_class) {
  #   class Article
  #     include Mongoid::Document
  #   end
  # }
  #
  # let(:article_serializer) {
  #   class ArticleSerializer < Matterhorn::BaseSerializer
  #   end
  # }

  # let!(:controller) do
  #   article_class
  #   article_serializer
  #
  #   define_class(:ArticlesController, Matterhorn::Base) do
  #     include Matterhorn::Resources
  #
  #     resources!
  #
  #     add_env :current_user
  #   end
  # end

  def app
    PostsController.action(:index)
  end

  request_path "/"
  request_method "GET"
  request_envs.merge! "HTTP_ACCEPT" => "application/json"

  let(:base_serialization_options) do
    {
      :prefixes=>["posts", "matterhorn/base"],
      :template=>"index",
      :url_options=> {
        :host=>"example.org",
        :port=>nil,
        :protocol=>"http://",
        :_recall=>{}
      },
      :collection_params=>{},
      :controller_inclusions=>{}
    }
  end

  it "should pass a memoized hash of envs from the controller" do
    @post = Post.make!
    stub_serializer = class_double(ActiveModel::DefaultSerializer, :new)
    PostsController.any_instance.stub(:current_user).and_return(user)

    request_env = Matterhorn::RequestEnv.new(current_user: user)

    expected_options = base_serialization_options.merge(request_env: request_env)

    expect(PostSerializer).to receive(:new).once.with(@post, expected_options).and_call_original

    perform_request!
  end

end
