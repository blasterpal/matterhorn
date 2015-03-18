require "matterhorn/inclusions/set_member"
require "matterhorn/serialization"

module Matterhorn
  module Inclusions
    class InclusionSet < Hash

      attr_reader :options
      attr_reader :config

      def initialize(config, options={})
        super()
        @options = options
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
    end

  end
end
