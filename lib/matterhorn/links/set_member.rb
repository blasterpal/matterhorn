module Matterhorn
  module Links
    class SetMember

      attr_reader :config
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :serializer
      attr_reader :relation_name
      attr_reader :resource_field_key
      attr_reader :template_key
      attr_reader :name

      def initialize(name, config, options={})
        @name             = name
        @config           = config
        @scope_class      = config.scope_class
        @context          = options[:context]
        @associated_tense = test_singularity(name) ? :singular : :plural
        @metadata         = config.metadata

        configure_for_relation!
      end

      def request_env
        Thread.current[:request_env]
      end

      def test_singularity(str)
        str = str.to_s
        str.pluralize != str && str.singularize == str
      end

      def scope_class
        @scope_class ||= (metadata || context).klass
      end

      def with_serializer(serializer)
        @serializer = serializer
        yield
        @serializer = nil
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

      def root_name
        config.as || name
      end

      def link_id
        serializer.send(resource_field_key)
      end

      def render?
        resource_field_key.blank? || (serializer.respond_to?(resource_field_key) && serializer.send(resource_field_key))
      end

      def full_url(url_builder)
        url_builder.send("#{build_url}_url", link_id)
      end

      def linkage(url_builder)
        link_type = scope_class.model_name.plural
        {
          linkage: {
            id:   link_id.to_s,
            type: link_type
          },
          related: full_url(url_builder)
        }
      end

    end
  end
end
