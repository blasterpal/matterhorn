require "spec_helper"
require "class_builder"

RSpec.describe "Matterhorn::Inclusions" do
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
    it "should have an inclusion" do
      expect(klass.new.inclusions[:author]).to be_kind_of(Matterhorn::Inclusions::SetMember )
    end
  end

  context "when adding InclusionSupport" do
    subject { klass }

    it { should respond_to(:add_inclusion) }

    context "and initialized" do
      let(:message) { klass.new }
      it { expect(message.inclusions).to be_a(Matterhorn::Inclusions::InclusionSet) }
    end

    it "should be mixed to controllers" do
      expect(PostsController.ancestors).to include(Matterhorn::Inclusions::InclusionSupport)
    end
  end

end
