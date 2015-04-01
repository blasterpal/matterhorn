module Matterhorn
  module Links
    module LinkSupport
      extend ActiveSupport::Concern
      include InheritableAccessors::InheritableHashAccessor

      included do
        inheritable_hash_accessor :__link_configs
      end

      def links(options={})
        @__links__ ||= Matterhorn::Links::LinkSet.new(__link_configs, options.merge(context: self))
      end

      module ClassMethods

        def add_link(name, options={}, &block)
          name = options.fetch(:as, name).to_sym 
          raise ArgumentError, 'link already defined' if __link_configs.has_key?(name)

          __link_configs[name] = ::Matterhorn::Links.build_link(self, name, options)
        end

      end

    end
  end
end
