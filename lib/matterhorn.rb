require "active_support/concern"
require "active_model_serializers"
require "inheritable_accessors"
require "matterhorn/version"
require "matterhorn/serialization"
require "matterhorn/inclusion"
require "matterhorn/controller/api"
require "matterhorn/resources"

module Matterhorn
  # Your code goes here...

  class ResourceError < StandardError
    DEFAULT_ERROR_CODE = 500
    attr_reader :status
    attr_reader :exception

    def initialize(exception)
      @exception = exception
      @status    = get_status_from_exception(exception)
    end

    def name
      @exception.to_s
    end

    def to_response_options
      {
        json:   Serialization::ErrorSerializer.new(self).serializable_hash,
        status: status
      }
    end

  protected ####################################################################

    def get_status_from_exception(ex)
      case ex
        when ::ActionController::UnknownFormat then 406
        else
          DEFAULT_ERROR_CODE
      end
    end

  end
end

if defined?(Rails)
  module Matterhorn
    class Railtie < Rails::Railtie
      initializer "serialization.matterhorn" do |app|
        [
          Matterhorn::Serialization::Scoped,
          Matterhorn::Serialization::ScopedCollectionSerializer
        ].each do |scope|
          scope.send :include, Rails.application.routes.url_helpers
        end
      end
    end
  end
end

ActiveModel::Serializer.send :prepend, Matterhorn::Serialization::BuilderSupport
