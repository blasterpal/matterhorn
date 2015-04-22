module Matterhorn
  module Links
    class SetMember

      attr_reader :config
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :name
      attr_reader :relation_name
      attr_reader :resource_field_key
      attr_reader :serializer
      attr_reader :template_key

      def initialize(name, config, options={})
        @name             = name
        @config           = config
        @scope_class      = config.scope_class
        @context          = options[:context]

        # TODO: this can be removed as we will keep name verbatum.
        #@associated_tense = test_singularity(name) ? :singular : :plural
        @metadata         = config.metadata
      end

      def request_env
        Thread.current[:request_env]
      end

      # TODO: removed
      #def test_singularity(str)
        #str = str.to_s
        #str.pluralize != str && str.singularize == str
      #end

      #def scope_class
        #@scope_class ||= (metadata || context).klass
      #end

      def with_serializer(serializer)
        @serializer = serializer
        yield
        @serializer = nil
      end

      def template_for(resource)
        Serialization::URITemplate.for(resource, @template_key.call(resource))
      end

      # TODO: removed
      #def with_tense(name)
        #@associated_tense == :singular ? name.to_s.singularize : name.to_s.pluralize
      #end

      ## TODO:  move this and other naming methods to another area.
      #def resource_name(resource)
        #result = case resource
        #when Mongoid::Document then resource.class.name
        #when Mongoid::Criteria then resource.klass.name
        #when Class             then resource.name
        #else
          #raise ArgumentError, "could not determine a name for '#{resource.inspect}'"
        #end

        #result.to_s.underscore.pluralize
      #end

      # TODO: removed
      #def root_name
        #config.as || name
      #end

      def link_id
        serializer.send(resource_field_key)
      end

      # TODO: this method should raise an error if it's misconfigured.
      def render?
        resource_field_key.blank? || (serializer.respond_to?(resource_field_key) && serializer.send(resource_field_key))
      end

      ## TODO: this needs to determine if nested or not, if not, then use objects matterhorn_url_options
      #def full_url(url_builder)
        #url_builder.send("#{build_url}_url", link_id)
      #end


    end
  end
end
