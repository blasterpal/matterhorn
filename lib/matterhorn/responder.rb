require "responders"

module Matterhorn
  class Responder < ::ActionController::Responder
    attr_reader :action

    def display(resource, options={})
      super resource, options
    end

    def default_render
      controller.render options.merge(json: resource, :content_type => Matterhorn::CONTENT_TYPE)
    end

    def display_errors
      # implement custom error responder to match JSON.api
      errors = Matterhorn::Serialization::ErrorSerializer.new(resource).serializable_hash
      controller.render json: errors , status: 422, :content_type => Matterhorn::CONTENT_TYPE
    end
  end
end
