module Matterhorn
  module Serialization
    class ErrorSerializer

      RESOURCE_ERROR = "resource_error"

      def initialize(object, options={})
        @object = object
      end

      #http://jsonapi.org/format/#errors
      # implementing the minimal that conforms with spec
      def serializable_hash
        if @object.class.ancestors.include?(ActiveModel::Model)
          return _model_errors
        end
        if @object.kind_of? Matterhorn::ResourceError
          return _exceptions 
        end
      end

      def _exceptions
        {
          errors: [
            title: @object.exception.class.name.underscore,
            detail: @object.exception.message,
            status: @object.status 
          ]
        }
      end

      def _model_errors
        all_the_errors = []
        @object.errors.messages.each do |key, error|
            problems = error.join(',')
            this_err = {
              title: RESOURCE_ERROR,
              detail: "#{key}: #{problems}",
              status: 422
            }
            all_the_errors << this_err
          end
        {errors: all_the_errors}
      end

    end
  end
end
