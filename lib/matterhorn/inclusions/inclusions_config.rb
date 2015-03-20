module Matterhorn
  module Inclusions

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

    class InclusionConfig

      attr_reader :base
      attr_reader :name
      attr_reader :options
      attr_reader :metadata
      attr_reader :foreign_key
      attr_reader :url_type

      DEFAULT_SCOPE = proc do |set_member|
        set_member.scope_class
      end

      def initialize(base, name, options={})
        @base        = base
        @name        = name

        @options     = options

        @scope    = options[:scope] || DEFAULT_SCOPE
        @url_type = options[:url_type] || :belongs_to
      end

      def base_class
        base
      end

      def scope(&block)
        if block_given?
          @scope = block
        else
          @scope
        end
      end

    end

  end
end
