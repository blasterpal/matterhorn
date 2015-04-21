require "spec_helper"

describe "Matterhorn::Serialization::ErrorSerializer" do
  context "resource" do
    let(:bad_resource) { Post.create }
    let(:response) { Matterhorn::Serialization::ErrorSerializer.new(bad_resource).serializable_hash }

    it "should return serialized errors" do
      error_titles = response[:errors].collect {|ea| ea[:title]}.uniq
      error_details = response[:errors].collect {|ea| ea[:detail]}
      expect(error_titles).to eq([Matterhorn::Serialization::ErrorSerializer::RESOURCE_ERROR])
      error_details.each do |detail|
        expect(["author: can't be blank", "title: can't be blank", "body: can't be blank" ]).to include(detail)
      end

    end
  end
end
