module Matterhorn
  module Serialization
    module Scoped
      extend ActiveSupport::Concern
      include Rails.application.routes.url_helpers

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

      def url_options
        options[:url_options]
      end

      def as_json(options={})
        serializable_hash
      end

      def merge_inclusions!(items, hash)
        collection_params = options[:collection_params]
        include_param     = collection_params.fetch(:include, "")

        inclusions = Inclusion::Inclusions.new(object, include_param, items, collection_ids)
        unless inclusions.available_inclusions.empty?
          inclusions.available_inclusions.each do |name, inclusion|
            hash["links"] ||= {}

            hash["links"][name] = "#{url_for(inclusion.scope.klass)}/{#{collection_name}.#{inclusion.foreign_key}}"
          end
        end


        unless inclusions.empty?
          hash.merge! "includes" => inclusions.serializable_hash
        end

        true
      end

      def merge_links!(hash)
        hash.merge! "links" => {}
      end
    end
  end
end