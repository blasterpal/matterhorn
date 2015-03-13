require 'matterhorn/spec_helpers/resourceful/collection_behaviors'

module Matterhorn
  module SpecHelpers
    module Resourceful
      extend ActiveSupport::Concern
      include CollectionBehaviors
    end
  end
end