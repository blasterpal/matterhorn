module Matterhorn
  module Links
    class Ordering < Collection

      def initialize(name,config,options={})
        super
      end

      def scope_url_options(resource)
        relation_scope(resource)
      end

      def self.is_valid_config?(link_config)
        link_config.name == :ordering
      end

      def url_options(resource)
        opts = super(resource)
        if opts and opts.last.kind_of?(Hash)
          opts.last.merge!(config.options[:order_params])
        else
          opts << config.options[:order_params]
        end
        opts
      end

      def scope_class(resource)
        resource_class(resource)
      end

    end
  end
end
