require "matterhorn/serialization/scoped/merge_inclusions"
require "matterhorn/serialization/scoped/merge_links"

module Matterhorn
  module Serialization

    module Scoped
      extend  ActiveSupport::Concern
      include Serialization::Scoped::MergeLinks
      include Serialization::Scoped::MergeInclusions

      ID_FIELD = :_id
    end

    class ScopedBase
      ID_FIELD = Scoped::ID_FIELD

      extend Forwardable

      attr_reader :object, :options, :collection_name, :resource_name, :ids, :request_env

      def_delegator :@url_builder, :url_for

      def initialize(object, options={})
        @object, @options = object, options.dup

        name = object.kind_of?(Enumerable) ? @object.klass.name : object.class.name

        @resource_name   = name.underscore
        @collection_name = @resource_name.pluralize
        @request_env     = options[:request_env]
        @url_builder     = options[:url_builder] || request_env[:url_builder]
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
          hash.merge!(TOP_LEVEL_KEY=> serialized_object)
        end
      end

      def as_json(options={})
        serializable_hash
      end

      def merge_inclusions!(hash)
        items = [serialized_object].flatten

        outbound_includes = []

        resource_params = request_env[:collection_params] || {}
        include_param   = resource_params.fetch(:include, "")

        requested_includes = include_param.split(",")

        link_set_options = { context: object, request_env: request_env }
        links = Links::LinkSet.new(object_link_config, link_set_options)

        results = []

        links.each do |pair|
          name, member = *pair

          if requested_includes.include?(name.to_s)
            results.concat member.find(object, items).to_a
          end
        end

        items = results.map do |result|
          if result.respond_to?(:active_model_serializer)

            result.active_model_serializer.new(result, options.merge(root: nil, request_env: request_env)).serializable_hash
          else
            result.as_json(options.merge(root: nil))
          end
        end

        hash.merge! "includes" => items
      end

      #
      #   within_env do
      #
      #     unless display_inclusions.empty?
      #       results = []
      #       display_inclusions.each do |name, member|
      #         results.concat member.find(self, items)
      #       end
      #
      #       items = results.map do |result|
      #         if result.respond_to?(:active_model_serializer)
      #           result.active_model_serializer.new(result, options.merge(root: nil)).serializable_hash
      #         else
      #           result.as_json(options.merge(root: nil))
      #         end
      #       end
      #
      #       hash.merge! "includes" => items
      #     end
      #
      #   end
      #
      #   true
      # end

    end
  end
end
