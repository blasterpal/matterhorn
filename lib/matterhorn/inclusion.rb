module Matterhorn
  class Inclusion
    attr_reader :base_class
    attr_reader :name
    attr_reader :options

    def initialize(base_class, name, options={})
      @base_class = base_class
      @name       = name
      @options    = {}
    end

    def find(context, items, ids)
      scope = base_class.reflect_on_association(name)
      foreign_key = scope.key.to_sym

      ids = get_items_ids(items, foreign_key)

      scope.klass.in(id: ids)
    end

    def get_items_ids(items, key)
      items.map do |item|
        item[key]
      end
    end

    # a list of things actually included during the request, should be able to
    # accept multiple context blocks (i.e. a controller, and a model)
    class Inclusions

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
            inclusion_meta = get_available_inclusions_for(context)[key.to_sym]

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

    private ######################################################################

      def get_available_inclusions_for(obj)
        obj.klass.inclusions.to_hash
      end

    end

    module InclusionSupport
      extend ActiveSupport::Concern
      include ::InheritableAccessors::InheritableHashAccessor

      included do
        inheritable_hash_accessor :inclusions
      end

      module ClassMethods

        def add_inclusion(name, options={})
          name = name.to_sym
          raise ArgumentError, 'inclusion already defined' if inclusions.has_key?(name)
          inclusions[name] = build_inclusion(name, options)
        end

        def build_inclusion(name, options={})
          Inclusion.new(self, name, options)
        end

      end

    end
  end

end