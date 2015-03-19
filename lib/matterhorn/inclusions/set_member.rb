module Matterhorn
  module Inclusions
    class SetMember

      attr_reader :name
      attr_reader :config
      attr_reader :context
      attr_reader :metadata
      attr_reader :foreign_key

      def initialize(name, config, options={})
        @name     = name
        @config   = config
        @context  = options[:context]

        if config.base.ancestors.include?(::Matterhorn::Base)
          @metadata = context.send(:read_resource_scope).klass.reflect_on_association(name)
        elsif config.base.ancestors.include?(Mongoid::Document)
          @metadata = config.base.reflect_on_association(name)
        end

        configure_for_relation!
      end

      def configure_for_relation!
        if metadata.relation == Mongoid::Relations::Referenced::In
          @foreign_key = metadata.foreign_key.to_sym
          @key = metadata.key.to_sym
        elsif metadata.relation == Mongoid::Relations::Referenced::Many

          @foreign_key = metadata.foreign_key.to_sym
          @key = metadata.key.to_sym
        else
          raise "undefined foreign key"
        end
      end

      def scope_class
        @scope_class = (metadata || context).klass
      end

      def find(context, items, ids)
        ids = get_items_ids(items, "_id")
        find_with_ids(ids)
      end

      def find_with_ids(ids)
        scope_class.in(foreign_key => ids)
      end

      def get_items_ids(items, key)
        items.map do |item|
          item[key.to_s]
        end
      end

    end
  end
end