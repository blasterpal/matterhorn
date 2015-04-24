require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::Relation::BelongsTo" do
  include ClassBuilder
  include UrlTestHelpers
  include SerialSpec::ItExpects

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
    define_class(:Article, base_class) do
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

  let(:author)     { Author.create }
  let(:article)    { article_class.create author: author}
  let(:set_member) { link_set[:author] }
  let(:link_set)   { Matterhorn::Links::LinkSet.new(article_class.__link_configs, context: Article, request_env: request_env)}

  it "should set relation to type Links::BelongsTo" do
    expect(set_member).to be_kind_of(Matterhorn::Links::BelongsTo)
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  context "when not nested" do

    context "when context: criteria" do
      let(:link_context) { Article.all }

      it "it should build with a url template" do
        expect(set_member.url_for(link_context)).to eq("http://example.org/authors/{articles.author_id}")
      end
    end

    context "when context: model" do
      let(:link_context) { article }

      it "should build a link to the actual resource" do
        expect(set_member.url_for(link_context)).to eq("http://example.org/authors/#{author._id}")
      end
    end

  end

  context "when nested" do

    routes_config do
      resources :articles do
        resource :author
      end
    end

    let!(:article_class) do
      define_class(:Article, base_class) do
        belongs_to :author
        add_link   :author,
          nested: true
      end
    end

    context "when context: criteria" do
      let(:link_context) { Article.all }

      it "it should build with a url template" do
        expect(set_member.url_for(link_context)).to eq("http://example.org/articles/{articles._id}/author")
      end
    end

    context "when context: model" do
      let(:link_context) { article }

      it "should build a link to the actual resource" do
        expect(set_member.url_for(link_context)).to eq("http://example.org/articles/#{article._id}/author")
      end
    end

  end

end
