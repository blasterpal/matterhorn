require "responders"

module Matterhorn
  module Controller
    class Responder < ::ActionController::Responder
      attr_reader :action

      def display(resource, options={})
        super resource, options
      end

      def default_render
        controller.render options.merge(json: resource)
      end

    end
  end
end