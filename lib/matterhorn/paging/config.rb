module Matterhorn
  module Paging
    class Config

      attr_accessor :pagination_class

      def initialize(options={})
        @pagination_class = options.fetch(:pagination_class, Matterhorn::Paging::Default)
      end

      def ==(other)
        pagination_class == other.pagination_class
      end

      def set_pagination_class(pagination_class)
        @pagination_class = pagination_class
      end
    end
  end
end
