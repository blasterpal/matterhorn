
require "matterhorn/serialization/scoped/link_support"

module Matterhorn
  module Serialization

    module Scoped
      extend  ActiveSupport::Concern
      include Serialization::Scoped::LinkSupport

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
          # merge_inclusions!(hash)
          hash.merge!(TOP_LEVEL_KEY=> serialized_object)
        end
      end

      def as_json(options={})
        serializable_hash
      end

      def within_env
        raise "error" if Thread.current[:request_env]
        Thread.current[:request_env] = request_env
        yield if block_given?
        Thread.current[:request_env] = nil
      end

      # def merge_inclusions!(hash)
      #   items = [serialized_object].flatten
      #
      #   resource_params = options[:collection_params] || {}
      #   include_param   = resource_params.fetch(:include, "")
      #
      #   model_inclusions = Inclusions::InclusionSet.new(object.__inclusion_configs, context: object)
      #   inclusions = options[:controller_inclusions].dup
      #   inclusions.merge!(model_inclusions.to_h)
      #   requested_includes = include_param.split(",")
      #
      #   display_inclusions = inclusions.dup
      #
      #   display_inclusions.select! do |name, member|
      #     requested_includes.include? name.to_s
      #   end
      #
      #   # Not really needed at the moment, but should be accessible set_members
      #   # to build links in the future.  I'll leave them commmented for the
      #   # moment.
      #   #
      #   # request_env[:links]      = inclusions
      #   # request_env[:inclusions] = display_inclusions
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
