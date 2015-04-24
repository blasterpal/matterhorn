require 'spec_helper'

RSpec.describe "Matterhorn::Links::LinkSet" do

  let(:link_set) { Matterhorn::Links::LinkSet.new({}) }

  it "should be serializable" do
    expect(link_set).to respond_to(:as_json)
  end

  context "#serializable_hash" do

    context "with self link in the set" do

      it "should have a self link when serialized"

    end

  end

end
