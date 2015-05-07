require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::Relation::HasAndBelongsToMany" do
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
      include Matterhorn::Links::LinkSupport
    end
  end

  let!(:article_class) do
    define_class(:Article, base_class) do
      has_and_belongs_to_many   :authors
      add_link   :authors,
        nested: true
    end
  end

  let!(:author_class) do
    define_class(:Author, base_class) do
      include Mongoid::Document

      field :name
    end
  end

  let!(:author)    { author_class.create }
  let!(:author_2)    { author_class.create }
  let(:article)    { article_class.create authors: [author, author_2] }
  let(:set_member) { link_set[:authors] }
  let(:link_set)   { Matterhorn::Links::LinkSet.new(article_class.__link_configs, context: article_class, request_env: request_env)}

  it "should set relation to type Links::HasAndBelongsToMany" do
    expect(set_member).to be_kind_of(Matterhorn::Links::Relation::HasAndBelongsToMany)
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:url) { set_member.url_for(link_context) }
  let(:serialized) { set_member.serialize(link_context) }
  let(:parsed_serialized) { SerialSpec::ParsedBody.new(serialized.to_json) }

  context "when not nested" do

    let!(:article_class) do
      define_class(:Article, base_class) do
        has_and_belongs_to_many   :authors
        add_link   :authors,
          nested: false 
      end
    end

    it 'should raise an error' do
      expect{set_member}.to raise_error(Matterhorn::Links::ConfigurationError)
    end
  end

  context "when nested" do

    routes_config do
      resources :articles do
        resource :authors
      end
    end

    let!(:article_class) do
      define_class(:Article, base_class) do
        has_and_belongs_to_many   :authors
        add_link   :authors,
          nested: true
      end
    end

    context "when context: criteria" do
      let(:link_context) { article_class.all }

      it { expect(url).to eq("http://example.org/articles/{articles._id}/authors") }
    end

    context "when context: model" do
      let(:link_context) { article }

      it { expect(url).to eq("http://example.org/articles/#{article._id}/authors") }
      it { expect(parsed_serialized[:linkage][0][:id].execute).to   eq(author._id.to_s) }
      it { expect(parsed_serialized[:linkage][0][:type].execute).to eq("authors") }
      it { expect(parsed_serialized[:linkage][1][:id].execute).to   eq(author_2._id.to_s) }
      it { expect(parsed_serialized[:linkage][1][:type].execute).to eq("authors") }

      context "no objects in relation" do
        let(:article)    { article_class.create }
        it { expect(parsed_serialized[:linkage].execute).to   eq([]) }
      end
    end
  end

  context "#find" do
    let(:link_context) { article }

    it "should return a enumerator of items matching the scope" do
      items = [article.serializable_hash]

      result = set_member.find([article])

      expect(result).to be_kind_of(Mongoid::Criteria)
      expect(result).to include(author)
    end
  end

end
