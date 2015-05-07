module Matterhorn
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from "ActionController::ActionControllerError", with: :handle_controller_error
    end

  protected ####################################################################

    def handle_controller_error(error)
      error = Matterhorn::ResourceError.new(error)
      render error.to_response_options.merge(:content_type => Matterhorn::CONTENT_TYPE)
    end
  end
end
