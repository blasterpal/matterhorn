require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"
require "matterhorn/serialization/scoped_collection_serializer"
require "matterhorn/serialization/scoped_resource_serializer"
require "matterhorn/serialization/error_serializer"

module Matterhorn
  module Serialization

    class InclusionSerializer < ActiveModel::Serializer
      attribute :name
    end

  end
end