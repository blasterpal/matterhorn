module Matterhorn
  module Serialization
    module BuilderSupport

      # this is a very explicit override of what activemodel serializers chooses
      # to do to serialize models.  Matterhorn ignores the root and context
      # (i.e. `current_user`) among other things.
      #
      #
      def build_json(controller, resource, options)
        options[:url_options]       = controller.url_options
        options[:collection_params] = controller.send(:collection_params)

        serializer = resource.kind_of?(Enumerable) ? ScopedCollectionSerializer : ScopedResourceSerializer
        ser = serializer.new(resource, options)
      end

    end
  end
end