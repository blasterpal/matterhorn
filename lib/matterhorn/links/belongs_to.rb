module Matterhorn
  module Links
    class BelongsTo < Matterhorn::Links::Association

      def configure_for_relation!
        @resource_field_key   = metadata.foreign_key.to_sym
        @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
      end

      def url_options(resource)
        [template_for(scope_class)]
      end

      def linkage(url_builder)
        link_type = scope_class.model_name.plural
        {
          linkage: {
            id:   link_id.to_s,
            type: link_type
          },
          # this changes depending on the type of relation?
          related: url_builder.send("#{self.link_resource_name}_url",link_id)
        }
      end

      # TODO: remove
      # This is add_link :name
      #def build_url
        #"#{scope_class.model_name.to_s.downcase.singularize}"
      #end

      def self.is_valid_config?(link_config)
        return false unless link_config.metadata
        link_config.metadata.relation == Mongoid::Relations::Referenced::In
      end

    end
  end
end
