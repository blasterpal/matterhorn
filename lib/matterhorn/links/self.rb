module Matterhorn
  module Links
    class Self < SetMember

      def self.is_valid_config?(link_config)
        link_config.name == :self
      end

    end
  end
end
