module Matterhorn
  module Links
    class Association < Matterhorn::Links::SetMember
      
      # MOAR association stuff will go here
      #
      def initialize(name,config,options={})
        super
        configure_for_relation!
      end

      def configure_for_relation!
        raise NotImplementedError
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

      def scope_class
        @scope_class ||= (metadata || context).klass
      end

      # TODO: this needs to be moved to a serializer or at least a separate file for serialization.
      # TODO: this doesn't work for links that are not associations.
      def linkage(url_builder)
        link_type = scope_class.model_name.plural
        {
          linkage: {
            id:   link_id.to_s,
            type: link_type
          },
          # this changes depending on the type of relation?
          related: url_builder.send("#{self.link_name}_url",link_id)
        }
      end

      def link_name
        relation_name || name
      end

    end
  end
end

