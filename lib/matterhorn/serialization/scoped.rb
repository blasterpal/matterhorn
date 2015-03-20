module Matterhorn
  module Serialization

    module Scoped
      extend ActiveSupport::Concern

      ID_FIELD = :_id

      included do
        extend Forwardable

        attr_reader :object, :options, :collection_name, :resource_name, :ids

        def_delegator :@url_builder, :url_for
      end

      def initialize(object, options={})
        @object, @options = object, options.dup

        name = object.kind_of?(Enumerable) ? @object.klass.name : object.class.name

        @resource_name   = name.underscore
        @collection_name = @resource_name.pluralize

        @url_builder = UrlBuilder.new url_options: options[:url_options]
      end

      def serialized_object
        @serialized_object ||= _serialized_object
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
        include_param   = resource_params.fetch(:include, "")

        inclusions = Inclusions::InclusionSet.new(object.__inclusion_configs, context: object) # resource
        inclusions.merge! options[:controller_inclusions]

        requested_includes = include_param.split(",")

        display_inclusions = inclusions.select do |name, member|
          requested_includes.include? name.to_s
        end

        unless inclusions.empty?
          inclusions.each do |name, inclusion|
            hash["links"] ||= {}

            url_for_opts = inclusion.url_options(object)
            hash["links"][name] = url_for(url_for_opts)
          end
        end

        unless display_inclusions.empty?

          results = []
          display_inclusions.each do |name, member|
            results.concat member.find(self, items, ids)
          end

          hash.merge! "includes" => results.map(&:serializable_hash)
        end

        true
      end

    end
  end
end
