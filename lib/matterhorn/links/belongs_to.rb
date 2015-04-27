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

      def with_materhorn_resource_opts(resource, opts)
        resource_class = Serialization.classify_name(resource)
        resource_class.respond_to?(:matterhorn_url_options) ? resource_class.matterhorn_url_options(opts) : [opts]
      end


      def url_options(resource)
        opts = case resource
        when Mongoid::Document then resource_url_options(resource)
        when Mongoid::Criteria then scope_url_options(resource)
        else
          raise "Could not decide how to build association from #{resource.inspect}"
        end

        opts = with_materhorn_resource_opts(resource, opts)
        config.nested ? [*opts, relation_name] : opts
      end

      def resource_url_options(resource)
        config.nested ? nested_member(resource) : relation_member(resource)
      end

      def scope_url_options(resource)
        template_for(relation_scope(resource))
      end

      def relation_scope(resource)
        config.nested ? resource : scope_class
      end

      def nested_member(resource)
        resource
      end

      def relation_member(resource)
        faux_resource_for(scope_class, resource.send(resource_field_key))
      end

      def faux_resource_for(resource, param)
        Matterhorn::UrlHelper::FauxResource.for(resource, param)
      end

      def url_for(resource)
        url_builder.url_for(url_options(resource))
      end

      # TODO: this needs to accept a resource param, like the other methods in this object.
      def linkage(url_builder)
        link_type = scope_class.model_name.plural
        {
          linkage: {
            id:   link_id.to_s,
            type: link_type
          },
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
