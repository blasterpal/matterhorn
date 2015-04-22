module Matterhorn
  module Links
    class BelongsTo < Matterhorn::Links::SetMember

      def configure_for_relation!
        @resource_field_key   = metadata.foreign_key.to_sym
        @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
      end

      def url_options(resource)
        [template_for(scope_class)]
      end

      # TODO: remove
      def build_url
        "#{scope_class.model_name.to_s.downcase.singularize}"
      end

    end
  end
end
