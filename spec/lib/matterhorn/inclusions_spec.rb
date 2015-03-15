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
      expect(klass.inclusions[:author]).to be_kind_of(Matterhorn::Inclusions::Inclusion)
    end
  end

end