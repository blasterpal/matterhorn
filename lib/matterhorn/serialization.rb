require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization

    class ScopedCollectionSerializer
      include Scoped

      attr_reader :collection_ids

      ID_FIELD = :_id

      def initialize(object, options={})
        super(object, options)
      end

      def serializable_hash
        hash = {}
        hash.merge!(collection_name => serialized_object)

        set_collection_ids(serialized_object)

        merge_inclusions! serialized_object, hash
        hash
      end

      def _serialized_object
        collection_serializer = ActiveModel::ArraySerializer.new(object.to_a, options)

        items = collection_serializer.serializable_array
        set_collection_ids(items)

        items
      end

      def set_collection_ids(items)
        @collection_ids = items.map do |item|
          item[ID_FIELD] || item[ID_FIELD.to_s]
        end
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
        hash = {}
        hash.merge!(resource_name => serialized_object)

        # merge_inclusions! [serialized_object], hash
        hash
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


  end
end