module Matterhorn
  module Inclusions
    class SetMember

      attr_reader :name
      attr_reader :config
      attr_reader :context
      attr_reader :foreign_key
      attr_reader :metadata

      def initialize(name, config, options={})
        @name     = name
        @config   = config
        @context  = options[:context]

        if config.base == PostsController
          @metadata = context.send(:read_resource_scope).klass.reflect_on_association(name)
          @foreign_key = @metadata.key.to_sym
        elsif config.base.ancestors.include?(Mongoid::Document)
          @metadata = config.base.reflect_on_association(name)
          @foreign_key = @metadata.key.to_sym
        end
      end

      def scope_class
        @scope_class = (metadata || context).klass
      end

      def find(context, items, ids)
        ids = get_items_ids(items, foreign_key)
        find_with_ids(ids)
      end

      def find_with_ids(ids)
        scope_class.in(id: ids)
      end

      def get_items_ids(items, key)
        items.map do |item|
          item[key]
        end
      end

    end
  end
end