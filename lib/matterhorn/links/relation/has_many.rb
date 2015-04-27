module Matterhorn
  module Links
    module Relation
      class HasMany < Relation::Base

        def initialize(name, config, options={})
          super(name, config, options)

          raise ConfigurationError, "only belongs_to associations can be configured as nested: false" unless config.nested
        end

        def configure_for_relation!
          @resource_field_key   = metadata.primary_key.to_sym
          @inverse_field_key    = metadata.foreign_key
          if resource_field_key
            @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
          else
            @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
          end
        end

        def self.is_valid_config?(link_config)
          return false unless link_config.metadata
          link_config.metadata.relation == Mongoid::Relations::Referenced::Many
        end

      end
    end
  end
end
