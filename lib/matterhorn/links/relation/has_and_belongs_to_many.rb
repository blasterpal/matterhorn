module Matterhorn
  module Links
    module Relation
      class HasAndBelongsToMany < Relation::Base

        def initialize(name, config, options={})
          super(name, config, options)

          raise ConfigurationError, "only belongs_to associations can be configured as nested: false" unless config.nested
        end

        def configure_for_relation!
          @resource_field_key   = metadata.primary_key.to_sym
          @inverse_field_key    = metadata.foreign_key
          @template_key = ->(resource) { "#{resource_name(context)}._id" }
        end

        def inverse_id
          inverse_field_key
        end

        def link_id_and_type(resource)
          klass = metadata.polymorphic? ? scope_class(resource) : metadata.class_name
          [resource.send(inverse_field_key), klass.to_s.underscore.pluralize]
        end

        def self.is_valid_config?(link_config)
          return false unless link_config.metadata
          link_config.metadata.relation == Mongoid::Relations::Referenced::ManyToMany
        end

        def includable?
          true
        end

        def find_with_ids(resource, ids)
          scope(resource).in(resource_field_key => ids)
        end

        def get_items_ids(resources_array)
          resources_array.map do |item|
            item.send(inverse_field_key)
          end.flatten
        end

        def serialize_resource(resource)

          link_id, link_type = link_id_and_type(resource)

          linkage = link_id.inject([]) do |li, id|
            aux = { "id" => id, type: link_type }
            li.append(aux)
            li
          end
        
          {
            linkage: linkage,
            related: url_for(resource)
          }
        end

      end
    end
  end
end
