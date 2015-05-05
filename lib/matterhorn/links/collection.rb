module Matterhorn
  module Links
    class Collection < SetMember
      def scope_url_options(resource)
        relation_scope(resource)
      end

      def scope_class(resource)
        resource_class(resource)
      end
    end
  end
end

