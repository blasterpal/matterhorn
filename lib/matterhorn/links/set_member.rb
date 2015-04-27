module Matterhorn
  module Links
    class SetMember
      attr_reader :config

      # Context is the current object being serialized.
      # This will generally be a Criteria, Model or a small array of context
      # objects (i.e. in the case of nested routes /posts/1,2,3/vote, the 3
      # posts would be an array).
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :name
      attr_reader :relation_name
      attr_reader :request_env
      attr_reader :resource_field_key
      attr_reader :serializer
      attr_reader :template_key

      def initialize(name, config, options={})
        @name             = name
        @config           = config
        @scope_class      = config.scope_class
        @context          = options[:context]
        @request_env      = options[:request_env]
        @relation_name    = config.relation_name

        # TODO: this can be removed as we will keep name verbatum.
        #@associated_tense = test_singularity(name) ? :singular : :plural
        @metadata         = config.metadata
      end

      def url_builder
        request_env[:url_builder]
      end

      def with_serializer(serializer)
        @serializer = serializer
        yield
        @serializer = nil
      end

      def template_for(resource)
        Serialization::URITemplate.for(resource, @template_key.call(resource))
      end

      def self.is_valid_config?(link_config)
        raise 'must be reimplemented'
      end

    end
  end
end
