require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::BaseSerializer" do

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

  let(:author)  { Author.create }
  let(:article) { article_class.create author: author}
  let(:serialized_article) { ArticleSerializer.new(article, root: nil, url_builder: url_builder).as_json }
  let(:body) { SerialSpec::ParsedBody.new(serialized_article.to_json) }

  subject { serialized_article }

  it "[REMOVE] should serialize without any errors" do
    expect(serialized_article).to be_a_kind_of(Hash)
  end

  it "should include links[self] reference" do
    expect(body[:links].execute).to be_kind_of(Hash)
    expect(body[:links][:self].execute).to eq(url_builder.article_url(article))
  end

  it "should serialize links specified in model" do
    relation = body[:links][:author]
    expect(relation[:related].execute).to        eq(url_builder.author_url(author))
    expect(relation[:linkage][:id].execute).to   eq(author._id.to_s)
    expect(relation[:linkage][:type].execute).to eq("authors")
  end

  # TODO:
  # context "when no routes provided" do
  #   it "should raise 'no routes defined for object'"
  # end

  context ".configure_matterhorn" do

    let(:serializer_class) do
      define_class(:ArticleSerializer, ActiveModel::Serializer)
    end

    it "should be included into ActiveModel::Serializer" do
      expect {
        serializer_class.configure_matterhorn
      }.to_not raise_error
    end

  end

end
