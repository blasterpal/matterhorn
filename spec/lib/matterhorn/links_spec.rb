require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links" do
  include ClassBuilder

  let(:base_class) do
    define_class(:BaseKlass) do
      include Mongoid::Document
      include Matterhorn::Inclusions::InclusionSupport
      include Matterhorn::Links::LinkSupport
    end
  end

  let(:klass) do
    define_class(:Message, base_class) do
      include Mongoid::Document
      include Matterhorn::Inclusions::InclusionSupport

      belongs_to :author, class_name: "User"
      add_inclusion :author
    end
  end

  context "when using `add_inclusion`" do
    it "should have a link" do
      expect(klass.new.links[:author]).to be_kind_of(Matterhorn::Links::SetMember)
    end
  end

  context "when adding InclusionSupport" do
    subject { klass }

    context "and initialized" do
      let(:message) { klass.new }
      it { expect(message.links).to be_a(Matterhorn::Links::LinkSet) }
    end
  end

  context "link_config testing" do
    include ClassBuilder
    include UrlTestHelpers
    include SerialSpec::ItExpects
    #
    # routes_config do
    #   resources :articles
    #   resources :authors
    # end

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

    # let!(:serializer_class) do
    #   define_class(:ArticleSerializer, Matterhorn::Serialization::BaseSerializer)do
    #     attributes :_id, :author_id
    #   end
    # end

    let(:author)  { Author.create }
    let(:article) { article_class.create author: author}
    # let(:serialized_article) { ArticleSerializer.new(article, root: nil, url_builder: url_builder).as_json }
    # let(:body) { SerialSpec::ParsedBody.new(serialized_article.to_json) }


    # subject { serialized_article }

    # it "should work" do
    #   expect(body[:links][:author][:related].execute).to eq("http://example.org/authors/#{author.id}")
    # end
    let(:link_config) { article_class.__link_configs[:author] }

    it "should set link config name" do
      expect(link_config.name).to eq(:author)
    end

    # relation_name: :votes,
    # scope:         scope,
    # nested:        true,
    # singleton:     true,
    # type:          linkset class

    context '#relation_name' do
      it "should infer relation_name from name if relation exists" do
        expect(link_config.relation_name).to eq(:author)
      end

      context "when relation doesn't exist" do
        let!(:article_class) do
          define_class(:Article, base_class) do
            add_link   :author
          end
        end

        # it "should set relation_name to nil" do
        #   expect(link_config.relation_name).to eq(nil)
        # end

      end
      # context "when relation_name is not a mongoid relation"

    end

    context '#type' do
      it "should infer type from relation_name" do
        expect(link_config.type).to eq(:belongs_to)
      end

      it "should raise and error when type cannot be found" do
        expect {
          define_class(:Article, base_class) do
            add_link   :author
          end
        }.to raise_error
      end

      context 'belongs_to' do
        let!(:article_class) do
          define_class(:Article, base_class) do
            belongs_to :author
            add_link   :author
          end
        end

        it "should infer belongs_to type to ':belongs_to'" do
          expect(link_config.type).to eq(:belongs_to)
        end

      end

      context 'has_many' do
        let(:link_config) { article_class.__link_configs[:authors] }

        let!(:article_class) do
          define_class(:Article, base_class) do
            has_many :authors
            add_link :authors
          end
        end

        it "should infer has_many type to ':has_many'" do
          expect(link_config.type).to eq(:has_many)
        end

      end

      context 'has_one' do
        let(:link_config) { article_class.__link_configs[:author] }

        let!(:article_class) do
          define_class(:Article, base_class) do
            has_one :author
            add_link :author
          end
        end

        it "should infer has_one type to ':has_one'" do
          expect(link_config.type).to eq(:has_one)
        end

      end

    end



    it "should accept 'singleton' option" do
      define_class(:Article, base_class) do
        has_many :authors
        add_link :author, relation_name: :authors, singleton: true
      end

      expect(Article.__link_configs[:author].singleton).to eq(true)
    end

    it "should accept 'nested' option" do
      define_class(:Article, base_class) do
        belongs_to :author
        add_link   :author, nested: true
      end

      expect(Article.__link_configs[:author].nested).to eq(true)
    end





  end

end
