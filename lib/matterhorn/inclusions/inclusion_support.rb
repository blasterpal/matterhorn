module Matterhorn
  module Inclusions
    module InclusionSupport
      extend ActiveSupport::Concern
      include InheritableAccessors::InheritableHashAccessor

      included do
        inheritable_hash_accessor :__inclusion_configs
      end

      def inclusions
        @__inclusions__ ||= InclusionSet.new(__inclusion_configs, context: self)
      end

      module ClassMethods

        def add_inclusion(name, options={}, &block)
          name = name.to_sym
          raise ArgumentError, 'inclusion already defined' if __inclusion_configs.has_key?(name)

          options[:scope] ||= block if block_given?

          __inclusion_configs[name] = ::Matterhorn::Inclusions.build_inclusion(self, name, options)
        end

      end

    end
  end
end