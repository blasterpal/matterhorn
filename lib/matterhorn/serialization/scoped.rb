module Matterhorn
  module Serialization
    module Scoped
      extend ActiveSupport::Concern
      include Rails.application.routes.url_helpers

      ID_FIELD = :_id

      included do
        attr_reader :object, :options, :collection_name, :resource_name, :ids
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

      def url_options
        options[:url_options]
      end

      def set_ids(*items)
        @ids = items.flatten.map do |item|
          item[ID_FIELD] || item[ID_FIELD.to_s]
        end
      end

      def serializable_hash
        set_ids(serialized_object)

        Hash.new.tap do |hash|
          merge_inclusions!(hash)
        end
      end

      def as_json(options={})
        serializable_hash
      end

      def merge_inclusions!(hash)
        items = [serialized_object].flatten

        resource_params = options[:collection_params] || {}
        include_param     = resource_params.fetch(:include, "")

        inclusions = Inclusions::InclusionSet.new(object, include_param, items, ids)
        unless inclusions.available_inclusions.empty?
          inclusions.available_inclusions.each do |name, inclusion|
            hash["links"] ||= {}
            hash["links"][name] = "#{url_for(inclusion.scope_class)}/{#{collection_name}.#{inclusion.foreign_key}}"
          end
        end

        unless inclusions.empty?
          hash.merge! "includes" => inclusions.serializable_hash
        end

        true
      end

    end
  end
end