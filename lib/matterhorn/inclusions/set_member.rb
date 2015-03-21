module Matterhorn
  module Inclusions
    class SetMember

      attr_reader :name
      attr_reader :config
      attr_reader :context
      attr_reader :metadata
      attr_reader :foreign_key

      attr_reader :resource_field_key
      attr_reader :inclusion_lookup_key
      attr_reader :template_key

      belongs_to = ->(resource) {
        [template_for(scope_class)]
      }

      has_one = ->(resource) {
        [template_for(resource), with_tense(name)]
      }

      URL_TYPE = {
        belongs_to: belongs_to,
        has_one:    has_one
      }

      def initialize(name, config, options={})
        @name     = name
        @config   = config
        @context  = options[:context]
        @url_type = config.url_type

        if config.base.ancestors.include?(::Matterhorn::Base)
          @metadata = context.send(:read_resource_scope).klass.reflect_on_association(name)
        elsif config.base.ancestors.include?(Mongoid::Document)
          @metadata = config.base.reflect_on_association(name)
        end

        configure_for_relation!
      end

      def configure_for_relation!
        if metadata.relation == Mongoid::Relations::Referenced::In
          @url_type             = :belongs_to
          @resource_field_key   = metadata.foreign_key.to_sym
          @inclusion_lookup_key = metadata.primary_key.to_sym
          @associated_tense = :plural
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        elsif metadata.relation == Mongoid::Relations::Referenced::Many
          @url_type             = :has_one
          @resource_field_key   = metadata.primary_key.to_sym
          @inclusion_lookup_key = metadata.foreign_key.to_sym
          @associated_tense = :singular
          @template_key = ->(resource) { "#{resource_name(resource)}.#{inclusion_lookup_key}" }
        else
          raise "undefined metadata.relation"
        end
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
          context.instance_exec(self, &config.scope)
        end
      end

      def url_options(resource)
        instance_exec(resource, &URL_TYPE[@url_type])
      end

      def template_for(resource)
        Serialization::URITemplate.for(resource, @template_key.call(resource))
      end

      def with_tense(name)
        @associated_tense == :singular ? name.to_s.singularize : name.to_s.pluralize
      end

      def resource_name(resource)
        result = case resource
        when Mongoid::Document then resource.class.name.to_s.underscore
        when Mongoid::Criteria then resource.klass.to_s.underscore
        when Class             then resource.name.to_s.underscore
        else
          raise ArgumentError, "could not determine a name for '#{resource.inspect}'"
        end

        @associated_tense == :singular ? result.singularize : result.pluralize
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
