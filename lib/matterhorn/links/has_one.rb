module Matterhorn
  module Links
    class HasOne < Matterhorn::Links::Association

      def configure_for_relation!
        @resource_field_key   = metadata.primary_key.to_sym
        @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
        @associated_tense = :singular
      end

      def url_options(resource)
        [template_for(resource), with_tense(name)]
      end

      # TODO: remove
      def build_url
        "#{context.class.name.downcase}_#{scope_class.model_name.singular}"
      end
    end
  end
end
