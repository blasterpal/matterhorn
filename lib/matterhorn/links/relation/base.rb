module Matterhorn
  module Links
    module Relation
      class Base < Links::SetMember

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

        def scope_class(reference=nil)
          @scope_class ||= (metadata || context).klass
        end

        # TODO: can this be removed?
        def link_resource_name
          l_name = relation_name || name
          if config.singleton
            l_name.to_s.singularize.to_sym
          else
            l_name
          end
        end

        def url_options(resource)
          opts = super(resource)
          config.nested ? [*opts, relation_name] : opts
        end

        def resource_url_options(resource)
          config.nested ? nested_member(resource) : relation_member(resource)
        end

        def scope_url_options(resource)
          template_for(relation_scope(resource))
        end

        def relation_scope(resource)
          config.nested ? resource : scope_class(resource)
        end

        def nested_member(resource)
          resource
        end

        def relation_member(resource)
          if metadata.polymorphic?
            faux_resource_for(scope_class(resource), resource.send(resource_field_key))
          else
            faux_resource_for(scope_class(resource), resource.send(resource_field_key))
          end
        end

        def faux_resource_for(resource, param)
          Matterhorn::UrlHelper::FauxResource.for(resource, param)
        end

        def self.is_valid_config?(link_config)
          return false unless link_config.metadata
          link_config.metadata.relation == Mongoid::Relations::Referenced::In
        end

        def inverse_id
          if @inverse_field_key.to_s == Serialization::Scoped::ID_FIELD.to_s
            "id"
          else
            @inverse_field_key
          end
        end

        # linkage and relate as a hash
        # TODO: possibly raise an error when the relations resource_field_key is
        #       not provide in the serializer.
        def serialize_resource(resource)
          link_id, link_type = link_id_and_type(resource)
          id_field = metadata.primary_key.to_s == Serialization::Scoped::ID_FIELD.to_s ? "id" : metadata.primary_key
          {
            linkage: {
              inverse_id => link_id,
              :type    => link_type
            },
            related: url_for(resource)
          }
        end

        def link_id_and_type(resource)
          klass = metadata.polymorphic? ? scope_class(resource) : metadata.class_name
          [resource.send(resource_field_key), klass.to_s.underscore.pluralize]
        end

        # just the url of the relationship
        def serialize_collection(collection)
          url_for(collection)
        end


      end
    end
  end
end
