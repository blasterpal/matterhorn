module Matterhorn
  module Inclusions
    module InclusionSupport
      extend ActiveSupport::Concern
      include InheritableAccessors::InheritableHashAccessor
      include Matterhorn::Links::LinkSupport

      included do
        inheritable_hash_accessor :__inclusion_configs
      end

      def inclusions(options={})
        @__inclusions__ ||= InclusionSet.new(__inclusion_configs, options.merge(context: self))
      end

      module ClassMethods

        def add_inclusion(name, options={}, &block)
          name = name.to_sym
          raise ArgumentError, 'inclusion already defined' if __inclusion_configs.has_key?(name)

          inclusion_config = ::Matterhorn::Inclusions.build_inclusion(self, name, options)
          __inclusion_configs[name] = inclusion_config
          add_link(name, options.merge(metadata: inclusion_config.metadata))
        end

      end

    end
  end
end
