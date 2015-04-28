module Matterhorn
  module Links
    class Self < SetMember

      def initialize(name,config,options={})
        super
        @template_key = ->(resource) { "#{resource_name(context)}._id" }
      end

      def self.is_valid_config?(link_config)
        link_config.name == :self
      end

      def scope_class(resource)
        resource_class(resource)
      end

    end
  end
end
