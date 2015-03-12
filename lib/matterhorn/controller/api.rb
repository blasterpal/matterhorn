require "matterhorn/controller/responder"
require "rails-api"

module Matterhorn
  module Controller
    class Api < ::ActionController::API

      respond_to :json
      self.responder = Responder
    end
  end
end