require 'spec_helper'

RSpec.describe "index" do
  collection_name "posts"
  resource_class Post
  resource_scope Post.all

  include Matterhorn::SpecHelpers::Resourceful::CollectionBehaviors
end