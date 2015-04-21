module Matterhorn
  module Inclusions
    class SetMember

      attr_reader :config
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :name
      attr_reader :relation_name
      attr_reader :resource_field_key
      attr_reader :template_key

      def initialize(name, config, options={})
        @name             = name
        @config           = config
        @context          = options[:context]
        @relation_name    = options[:relation_name] || name
        @associated_tense = test_singularity(name) ? :singular : :plural
        @metadata         = config.metadata
        configure_for_relation!
      end

      def request_env
        Thread.current[:request_env]
      end

      def configure_for_relation!
        if metadata.relation == Mongoid::Relations::Referenced::In
          @url_type             = :belongs_to
          @resource_field_key   = metadata.foreign_key.to_sym
          @inclusion_lookup_key = metadata.primary_key.to_sym

          # NOTE: this feels inaccurate. set_member or the inclusion_set should
          # probably have an accessor set in some kind of yield that will allow
          # the set_member visibility to the association parent (or maybe
          # the association_chain?).
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        elsif metadata.relation == Mongoid::Relations::Referenced::Many
          @url_type             = :has_one
          @resource_field_key   = metadata.primary_key.to_sym
          @inclusion_lookup_key = metadata.foreign_key.to_sym
          @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
        else
          raise "undefined metadata.relation"
        end
      end

      def test_singularity(str)
        str = str.to_s
        str.pluralize != str && str.singularize == str
      end

      def scope_class
        @scope_class = (metadata || context).klass
      end

      def find(context, items)
        ids = get_items_ids(items, resource_field_key)
        find_with_ids(ids)
      end

      def scope
        @scope ||= begin
          instance_exec(self, request_env, &config.scope)
        end
      end

      def with_tense(name)
        @associated_tense == :singular ? name.to_s.singularize : name.to_s.pluralize
      end

      def resource_name(resource)
        result = case resource
        when Mongoid::Document then resource.class.name
        when Mongoid::Criteria then resource.klass.name
        when Class             then resource.name
        else
          raise ArgumentError, "could not determine a name for '#{resource.inspect}'"
        end

        result.to_s.underscore.pluralize
      end

      def find_with_ids(ids)
        scope.in(inclusion_lookup_key => ids)
      end

      def get_items_ids(items, key)
        items.map do |item|
          item.with_indifferent_access[key]
        end
      end

    end
  end
end
