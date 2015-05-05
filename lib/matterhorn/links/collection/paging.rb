module Matterhorn
  module Links
    class Paging < Collection

      def self.is_valid_config?(link_config)
        link_config.name == :paging
      end

      def url_options(resource)
        opts = super(resource)
        if opts and opts.last.kind_of?(Hash)
          opts.last.merge!(config.options[:page_params])
        else
          opts << config.options[:page_params]
        end
        opts
      end

    end
  end
end
