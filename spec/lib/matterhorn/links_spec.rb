require "spec_helper"
require "class_builder"

RSpec.describe "Matterhorn::Links" do
  include ClassBuilder

  let(:klass) do
    define_class(:Message) do
      include Mongoid::Document
      include Matterhorn::Inclusions::InclusionSupport

      belongs_to :author, class_name: "User"
      add_inclusion :author
    end
  end

  context "when using `add_inclusion`" do
    it "should have a link" do
      expect(klass.new.links[:author]).to be_kind_of(Matterhorn::Links::SetMember )
    end
  end

  context "when adding InclusionSupport" do
    subject { klass }

    context "and initialized" do
      let(:message) { klass.new }
      it { expect(message.links).to be_a(Matterhorn::Links::LinkSet) }
    end
  end

end
