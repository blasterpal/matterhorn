module Matterhorn
  module Links
    module Relation
      class HasAndBelongsToMany < Relation::Base

        def initialize(name, config, options={})
          super(name, config, options)

          raise ConfigurationError, "only belongs_to associations can be configured as nested: false" unless config.nested
        end

        def configure_for_relation!
          @resource_field_key   = metadata.foreign_key.to_sym || []
          @inverse_field_key    = "id"
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

      end
    end
  end
end
