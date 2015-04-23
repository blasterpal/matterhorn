module Matterhorn
  module Links
    module LinkSupport
      extend ActiveSupport::Concern
      include InheritableAccessors::InheritableHashAccessor

      included do
        inheritable_hash_accessor :__link_configs
      end

      def links(options={})
        @__links__ ||= Matterhorn::Links::LinkSet.new(__link_configs, options.merge(context: self))
      end

      module ClassMethods

        # Adds a LinkConfig to a model or controller, which adds an associated
        # to the current model.
        #
        # name    - The String name is the key used to access the json
        #           representation of both the top level link and links on
        #           resources in json lists.
        #
        # opts - The Hash opts used to refine the selection (default: {}):
        #        :relation_name - The name of a relation this link is
        #                         referencing. This is generally a mongoid
        #                         relation.  This will default to the `name`.
        #                         (optional)
        #        :scope         - A scope that can be used to further refine
        #                         results of a collection.  This is mostly
        #                         useful for cases where you have a has_many
        #                         relation on your model, but want to use a
        #                         scope to create a singleton.  Defaults to
        #                         relation.all. (optional)
        #        :nested        - Should this prefer to use nested url
        #                         construction (e.g. /post/1/votes) or not
        #                         (e.g. /votes/1)
        #        :singleton     - Is this a singleton resource in the
        #                         controller? Defaults to name's plurality.
        #                         (optional)
        #
        def add_link(name, opts={}, &block)
          name = options.fetch(:as, name).to_sym
          raise ArgumentError, 'link already defined' if __link_configs.has_key?(name)

          __link_configs[name] = ::Matterhorn::Links.build_link(self, name, options)
        end

      end

    end
  end
end
