require "matterhorn/inclusions/set_member"
require "matterhorn/serialization"

module Matterhorn
  module Inclusions
    class InclusionSet

      extend Forwardable

      def_delegators :config, :[], :[]=, :each, :inspect, :to_h, :merge!, :select!, :empty?, :inject

      attr_reader   :options
      attr_reader   :config

      def initialize(config, opts={})
        @options = opts.dup

        @config = config.to_hash.inject(Hash.new) do |members, pair|
          name, meta = *pair
          name = name.to_sym
          members[name] = SetMember.new(name, meta, options)
          members
        end
      end

      def active_model_serializer
        ::Matterhorn::Serialization::InclusionSerializer
      end

      def dup
        is = InclusionSet.new({})
        is.set_config(@config.dup)
        is
      end

      def ==(other)
        config == other.config
      end

      protected

      def set_config(hsh)
        @config = hsh
      end

    end
  end
end
