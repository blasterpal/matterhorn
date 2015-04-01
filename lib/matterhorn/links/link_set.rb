require "matterhorn/inclusions/set_member"
require "matterhorn/serialization"

module Matterhorn
  module Links
    class LinkSet

      extend Forwardable

      def_delegators :config, :[], :[]=, :each, :inspect, :to_h, :merge!, :select!, :empty?, :inject
      attr_reader   :options
      attr_reader   :config

      def initialize(config, opts={})
        @options = opts.dup

        @config = config.to_hash.inject(Hash.new) do |members, pair|
          name, meta = *pair
          name = name.to_sym

          if belongs_to?(meta)
            link = Links::BelongsTo.new(name, meta, options)
          elsif has_one?(meta)
            link = Links::HasOne.new(name, meta, options)
          elsif has_many?(meta)
            link = Links::HasMany.new(name, meta, options)
          end
          members[name] = link
          members
        end
      end

      def belongs_to?(meta)
        meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::In
      end

      def has_one?(meta)
        meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::Many and meta.options[:as_singleton]
      end

      def has_many?(meta)
        meta.options[:has_many] || meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::Many
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

      def build_linkage(url_builder, serializer)
        inject(Hash.new) do |i, pair|
          name, link = *pair
          if link.render?(serializer)
            i.merge!(link.root_name => link.linkage(url_builder, serializer))
          end
          i
        end
      end

      protected

      def set_config(hsh)
        @config = hsh
      end

    end
  end
end
