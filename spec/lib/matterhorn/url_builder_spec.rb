require "spec_helper"

RSpec.describe 'Matterhorn::Serialization' do
  UrlBuilder  = Matterhorn::Serialization::UrlBuilder
  URITemplate = Matterhorn::Serialization::URITemplate

  let(:url_builder) { UrlBuilder.new url_options: { host: "example.org" }}

  context "UrlBuilder" do

    it "should construct urls based on named routes" do
      url = url_builder.url_for([:posts])

      expect(url).to eq("http://example.org/posts")
    end

    context "when invalid" do

      it "should raise_error" do
        url = -> { url_builder.url_for([:foo]) }

        expect(url).to raise_error
      end

    end

  end

  context "URITemplate" do
    include SerialSpec::ItExpects

    let(:param)    { "posts.id" }
    let(:resource) { @resource ||= Post.make! }
    let(:template) { URITemplate.for(resource, param)}
    let(:url)      { url_builder.url_for(template)}

    it_expects(:url) { expect(url).to eq("http://example.org/posts/{posts.id}") }

    it "should unescape routes returned" do
      # do nothing
    end

    it "should build from class level" do
      @resource = Post
    end

    it "should build from a criteria" do
      @resource = Post.all
    end

    it "should build from a new instance" do
      @resource = Post.make
    end

  end

end
