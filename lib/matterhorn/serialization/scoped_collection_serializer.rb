require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class ScopedCollectionSerializer
      include Scoped

      def serializable_hash
        super.merge!(TOP_LEVEL_KEY => serialized_object)
      end

      def request_env
        options[:request_env]
      end

      def order_config
        request_env[:order_config]
      end

      def _serialized_object
        if order_config
          order_name =  (options[:collection_params][:order] || order_config.default_order)
          order_by   = order_config.order_for(order_name)
          @object = object.order_by(order_by)
        end
        collection_serializer = ActiveModel::ArraySerializer.new(object.to_a, options)

        collection_serializer.serializable_array
      end

    end
  end
end
