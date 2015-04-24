module Matterhorn
  module Links
    class BelongsTo < Matterhorn::Links::Association

      def configure_for_relation!
        @resource_field_key   = metadata.foreign_key.to_sym
        if config.nested
          @template_key = ->(resource) { "#{resource_name(context)}._id" }
        else
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        end
      end

      def url_options(resource)
        if config.nested
          case resource
          when Mongoid::Document then [resource, relation_name]
          when Mongoid::Criteria then [template_for(resource), relation_name]
          else
            raise "error"

          end
        else
          case resource
          when Mongoid::Document then [faux_resource_for(scope_class, resource.send(resource_field_key))]
          when Mongoid::Criteria then [template_for(scope_class)]
          else
            raise "error"

          end
        end
      end

      def faux_resource_for(resource, param)
        Matterhorn::UrlHelper::FauxResource.for(resource, param)
      end

      def url_for(resource)
        url_builder.url_for(url_options(resource))
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
