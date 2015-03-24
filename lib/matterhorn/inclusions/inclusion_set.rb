require "matterhorn/inclusions/set_member"
require "matterhorn/serialization"

module Matterhorn
  module Inclusions
    class InclusionSet < Hash

      attr_reader   :options
      attr_reader   :config
      attr_accessor :serialization_env

      def initialize(config, opts={})
        super()
        @options = opts.dup
        @serialization_env = @options.delete(:serialization_env)

        @config  = config.to_hash
        results =  @config.inject(Hash.new) do |members, pair|
          name, meta = *pair
          name = name.to_sym
          members[name] = SetMember.new(name, meta, options)
          members
        end

        self.merge! results
      end

      def active_model_serializer
        ::Matterhorn::Serialization::InclusionSerializer
      end

      def each(&block)
        within_set do
          super()
        end
      end

      def within_set
        raise "error" if Thread.current[:inclusion_set]
        Thread.current[:inclusion_set] = self
        yield if block_given?
        Thread.current[:inclusion_set] = nil
      end

    end

  end
end
