module Matterhorn
  module Serialization
    module Scoped
      extend ActiveSupport::Concern

      included do
        attr_reader :object, :options, :collection_name, :resource_name
      end

      def initialize(object, options={})
        @object, @options = object, options

        name = object.kind_of?(Enumerable) ? @object.klass.name : object.class.name

        @resource_name   = name.underscore
        @collection_name = @resource_name.pluralize
      end

      def serialized_object
        @serialized_object ||= _serialized_object
      end

      def as_json(options={})
        serializable_hash
      end

      def merge_inclusions!(items, hash)
        collection_params = options[:collection_params]
        include_param     = collection_params.fetch(:include, "")

        inclusions = Inclusion::Inclusions.new(object, include_param, items, collection_ids)

        unless inclusions.empty?
          hash.merge! "includes" => inclusions.serializable_hash
        end

        true
      end
    end
  end
end