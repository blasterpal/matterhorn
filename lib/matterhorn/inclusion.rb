module Matterhorn
  module Inclusions

    def self.build_inclusion(base_class, name, options={})
      Inclusion.new(base_class, name, options)
    end

    class Inclusion

      # the class originating the scope.  Initially matterhorn will provide 2
      # different locations for the scope to be defined: Controller and a
      # model.
      #
      # During serialization, an instance of the base_class should be provided
      # as context. This allows associations defined in the controller to have
      # accessibilty to helper_methods (e.g. `current_user`), or in model (not
      # really a great case for it here except to provide common inclusions any
      # place that the model is used in the api).
      #
      # Usage:
      #
      #     class Post
      #       include Mongoid::Docuument
      #       include Matterhorn::Inclusions::InclusionSupport
      #
      #       belongs_to :author
      #       add_inclusion :author
      #     end
      #
      attr_reader :base_class
      attr_reader :name
      attr_reader :options
      attr_reader :metadata
      attr_reader :foreign_key

      def initialize(base_class, name, options={})
        @base_class  = base_class
        @name        = name
        @options     = options
        @metadata    = @base_class.reflect_on_association(name)
        @foreign_key = @metadata.key.to_sym
      end

      def find(context, items, ids)
        ids = get_items_ids(items, foreign_key)
        find_with_ids(ids)
      end

      def find_with_ids(ids)
        scope.in(id: ids)
      end

      def scope_class
        metadata.klass
      end

      def scope
        scope_class.all
      end

      # TODO: this doesn't belong here, possibly in some kind of third party
      #       method or class that handles extracting ids out of the current
      #       serialization scope.
      def get_items_ids(items, key)
        items.map do |item|
          item[key]
        end
      end

    end

    class SetMember

      attr_reader :name
      attr_reader :metadata
      attr_reader :context

      def initialize(name, metadata, options={})
        @name     = name
        @metadata = metadata
        @context  = options[:context]
      end

    end

    # a list of things actually included during the request, should be able to
    # accept multiple context blocks (i.e. a controller, and a model)
    #
    # This is actually a big pain point, really this should be an object
    # produced by both the controller and resource object during request.
    #
    # InclusionSet should have a merge method, and controller resource
    # inclusions INTO resoruce inclusions.  **Controllers should have
    # preference**. Once a merged set has been constructed, another method
    # should accept requested names from the current request cycle.  This is in
    # effect performing a select statement on those items.
    #
    class InclusionSet < Hash
      include Enumerable

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

    class InclusionList

      attr_reader :context
      attr_reader :keys
      attr_reader :items
      attr_reader :ids

      def initialize(context, include_param, items, ids)
        @context = context
        @items   = items
        @keys    = include_param.split(",")
        @ids     = ids
      end

      def process_inclusions
        @inclusions ||= begin
          sum = Hash.new
          keys.each do |key|
            inclusion_meta = available_inclusions[key.to_sym]

            next unless inclusion_meta
            sum[key]  = inclusion_meta.find(self, items, ids)
            sum
          end

          sum
        end
      end

      def empty?
        process_inclusions.empty?
      end

      def serializable_hash
        process_inclusions
      end

      def available_inclusions
        if defined?(context.klass.inclusions)
          context.klass.inclusions.to_hash
        else
          {}
        end
      end

    end

    module InclusionSupport
      extend ActiveSupport::Concern
      include ::InheritableAccessors::InheritableHashAccessor

      included do
        inheritable_hash_accessor :__inclusion_configs
      end


      def inclusions
        @__inclusions__ ||= InclusionSet.new(__inclusion_configs, context: self)
      end

      module ClassMethods

        def inclusions
          InclusionSet.new(__inclusion_configs, context: self)
        end

        def add_inclusion(name, options={})
          name = name.to_sym
          raise ArgumentError, 'inclusion already defined' if __inclusion_configs.has_key?(name)
          __inclusion_configs[name] = ::Matterhorn::Inclusions.build_inclusion(self, name, options)
        end

      end

    end
  end

end