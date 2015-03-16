require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization

    class ScopedCollectionSerializer
      include Scoped

      def initialize(object, options={})
        super(object, options)
      end

      def serializable_hash
        super.merge!(collection_name => serialized_object)
      end

      def _serialized_object
        collection_serializer = ActiveModel::ArraySerializer.new(object.to_a, options)

        collection_serializer.serializable_array
      end

    end

    class ScopedResourceSerializer
      include Scoped

      def initialize(object, options={})
        super(object, options)

        @serializer = options.delete(:serializer) ||
          (object.respond_to?(:active_model_serializer) &&
           object.active_model_serializer)
      end

      def serializable_hash
        super().merge!(resource_name => serialized_object)
      end

      def _serialized_object
        @serializer.new(object, options).serializable_hash
      end

    end

    class ErrorSerializer
      def initialize(object, options={})
        @object = object
      end

      def serializable_hash
        {
          error: @object.name
        }
      end

    end

    class InclusionSerializer < ActiveModel::Serializer
      attribute :name
    end


  end
end