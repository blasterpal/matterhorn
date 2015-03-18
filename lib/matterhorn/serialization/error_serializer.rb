module Matterhorn
  module Serialization
    class ErrorSerializer

      def initialize(object, options={})
        @object = object
      end

      def serializable_hash
        {
          error: @object.name
        }
      end

    end
  end
end