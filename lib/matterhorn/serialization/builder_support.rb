module Matterhorn
  module Serialization
    module BuilderSupport

      module ActiveModelSerializersPatch
        # this is a very explicit override of what activemodel serializers chooses
        # to do to serialize models.  Matterhorn ignores the root and context
        # (i.e. `current_user`) among other things.
        #
        #
        def build_json(controller, resource, options)
          options[:url_options]           = controller.url_options
          options[:collection_params]     = controller.send(:collection_params)
          serialization_env = controller.serialization_env_names.to_a.inject(Hash.new) do |sum, name|
            sum[name] = controller.send(name)
            sum
          end

          options[:controller_inclusions] = controller.inclusions
          options[:request_env] = RequestEnv.new(serialization_env)

          # TODO remove options url_builder
          options[:request_env][:url_builder] = options[:url_builder] = UrlBuilder.new url_options: options[:url_options]

          return resource if resource.kind_of?(Hash)

          serializer = resource.kind_of?(Enumerable) ? ScopedCollectionSerializer : ScopedResourceSerializer
          ser = serializer.new(resource, options)
        end

      end

      def self.prepended(base)
        class << base
          prepend ActiveModelSerializersPatch
        end
      end

    end
  end
end
