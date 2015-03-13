require "matterhorn/controller/responder"
require "rails-api"

module Matterhorn
  module Controller
    class Api < ::ActionController::API

      respond_to :json
      self.responder = Responder

      rescue_from "ActionController::ActionControllerError", with: :handle_controller_error

    protected

      def handle_controller_error(error)
        error = Matterhorn::ResourceError.new(error)
        render error.to_response_options
      end

    end
  end
end