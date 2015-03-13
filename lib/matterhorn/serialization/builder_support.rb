module Matterhorn
  module Serialization
    module BuilderSupport

      module ClassMethods
        # this is a very explicit override of what activemodel serializers chooses
        # to do to serialize models.  Matterhorn ignores the root and context
        # (i.e. `current_user`) among other things.
        #
        #
        def build_json(controller, resource, options)
          options[:url_options]       = controller.url_options
          options[:collection_params] = controller.send(:collection_params)

          return resource if resource.kind_of?(Hash)

          serializer = resource.kind_of?(Enumerable) ? ScopedCollectionSerializer : ScopedResourceSerializer
          ser = serializer.new(resource, options)
        end
      end

      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end

    end
  end
end