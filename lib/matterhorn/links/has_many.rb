module Matterhorn
  module Links
    class HasMany < Matterhorn::Links::Association

      def configure_for_relation!
        @resource_field_key   = config.resource_field_key
        if resource_field_key
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        else
          @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
        end
      end

      def url_options(resource)
        if resource_field_key
          [template_for(scope_class)]
        else
          [template_for(resource), link_resource_name]
        end
      end

      def link_id
        if resource_field_key
          serializer.send(resource_field_key).join(",")
        else
          serializer._id
        end
      end

      # TODO: remove
      def build_url
        if resource_field_key
          "#{scope_class.model_name.to_s.downcase.singularize}"
        else
          "#{context.class.name.downcase}_#{scope_class.model_name.to_s.downcase.pluralize}"
        end
      end

      def full_url(url_builder)
        if resource_field_key
          super
        else
          url_builder.send("#{build_url}_url", link_id)
        end
      end
    end
  end
end
