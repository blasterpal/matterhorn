require 'spec_helper'

RSpec.describe "index" do

  class_attribute :collection_name
  class_attribute :resource_class
  class_attribute :resource_scope

  self.collection_name = "posts"
  self.resource_class = Post
  self.resource_scope = Post.all

  include Matterhorn::SpecHelpers::Resourceful::CollectionBehaviors
end