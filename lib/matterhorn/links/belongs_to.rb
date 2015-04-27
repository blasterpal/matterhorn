module Matterhorn
  module Links
    class BelongsTo < Matterhorn::Links::Association

      def configure_for_relation!
        @resource_field_key   = metadata.foreign_key.to_sym
        @inverse_field_key    = metadata.primary_key
        if config.nested
          @template_key = ->(resource) { "#{resource_name(context)}._id" }
        else
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        end
      end

      def scope_class(resource)
        if metadata.polymorphic?
          type_field_key = "#{metadata.name}_type"
          resource.send(type_field_key).safe_constantize
        else
          super()
        end
      end

    end
  end
end
