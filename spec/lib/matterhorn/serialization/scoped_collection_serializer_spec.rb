require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::ScopedCollectionSerializer" do

  include ClassBuilder
  include UrlTestHelpers

  routes_config do
    resources :articles
    resources :authors
  end

  let(:base_class) do
    define_class(:BaseKlass) do
      include Mongoid::Document
      include Matterhorn::Inclusions::InclusionSupport
      include Matterhorn::Links::LinkSupport
    end
  end

  let!(:article_class) do
    define_class(:Article,base_class) do
      belongs_to :author
      add_link   :author
    end
  end

  let!(:author_class) do
    define_class(:Author) do
      include Mongoid::Document
      field :name
    end
  end

  let!(:serializer_class) do
    define_class(:ArticleSerializer, Matterhorn::Serialization::BaseSerializer) do
      attributes :_id, :author_id
    end
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:serializer) { Matterhorn::Serialization::ScopedCollectionSerializer.new(Article.all, root: nil, request_env: request_env) }
  let(:body) { SerialSpec::ParsedBody.new(serializer.to_json) }

  subject { serializer }

  it "should have top level self link" do
    expect(body[:links][:self].execute).to eq("http://example.org/articles/{articles._id}")
  end

  it "should have author top level" do
    expect(body[:links][:author].execute).to eq("http://example.org/authors/{articles.author_id}")
  end

  context "when no links are specified, and inclusion_support is not mixed" do
    let(:base_class) do
      define_class(:BaseKlass) do
        include Mongoid::Document
      end
    end

    let!(:article_class) do
      define_class(:Article,base_class) do
        belongs_to :author
      end
    end

    it "should not raise an error" do
      article = Article.create!

      expect{body[:links].execute}.to_not raise_error
    end

  end

end
