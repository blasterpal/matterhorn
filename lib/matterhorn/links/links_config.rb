module Matterhorn
  module Links

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
    #       include Matterhorn::Links::InclusionSupport
    #
    #       belongs_to :author
    #       add_inclusion :author
    #     end
    #

    class LinkConfig

      attr_reader :base
      attr_reader :name
      attr_reader :as
      attr_reader :options
      attr_reader :metadata
      attr_reader :scope_class
      attr_reader :resource_field_key
      attr_reader :url_type

      def initialize(base, name, options={})
        @base        = base
        @name        = name

        @options     = options
        @as          = options[:as]

        @metadata    = options[:metadata]

        @resource_field_key = options[:resource_field] 
        @scope_class        = options[:scope_class]

      end

      def base_class
        base
      end

    end
  end
end
