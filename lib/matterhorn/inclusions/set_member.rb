module Matterhorn
  module Inclusions
    class SetMember

      attr_reader :config
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :relation_name
      attr_reader :resource_field_key
      attr_reader :template_key
      attr_reader :name

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
        @name             = name
        @config           = config
        @context          = options[:context]
        @url_type         = config.url_type
        @relation_name    = options[:relation_name] || name
        @associated_tense = test_singularity(name) ? :singular : :plural

        if config.base.ancestors.include?(::Matterhorn::Base)
          @metadata_base = context.send(:read_resource_scope).klass
        elsif config.base.ancestors.include?(Mongoid::Document)
          @metadata_base = config.base
        end

        construct_metadata!
        configure_for_relation!
      end

      def request_env
        Thread.current[:request_env]
      end

      def construct_metadata!
        base = if config.base.ancestors.include?(Matterhorn::Base)
          context.send(:read_resource_scope).klass
        elsif config.base.ancestors.include?(Mongoid::Document)
          config.base
        else

          raise StandardError, "could not construct metadata from '#{config.inspect}'"
        end

        @metadata = base.reflect_on_association(relation_name)
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

        result.pluralize
      end

      def find_with_ids(ids)
        scope.in(inclusion_lookup_key => ids)
      end

      def get_items_ids(items, key)
        items.map do |item|
          item.with_indifferent_access[key]
        end
      end

      def linkage(url_builder)
        link_id   = context[resource_field_key].to_s
        link_type = scope_class.model_name.plural

        {
          linkage: {
            id:   link_id,
            type: link_type
          },
          related: url_builder.send("#{scope_class.model_name.singular}_url", link_id)
        }
      end

    end
  end
end
