require "responders"

module Matterhorn
  class Responder < ::ActionController::Responder
    attr_reader :action

    def display(resource, options={})
      super resource, options
    end

    def default_render
      controller.render options.merge(json: resource)
    end

  end
  module Controller
    Responder = ::Matterhorn::Responder
  end
end