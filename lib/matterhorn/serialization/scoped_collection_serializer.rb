require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class ScopedCollectionSerializer
      include Scoped

      def serializable_hash
        super.merge!(TOP_LEVEL_KEY => serialized_object)
      end

      def _serialized_object
        collection_serializer = ActiveModel::ArraySerializer.new(object.to_a, options)

        collection_serializer.serializable_array
      end

    end
  end
end
