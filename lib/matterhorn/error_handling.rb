module Matterhorn
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from "ActionController::ActionControllerError", with: :handle_controller_error
    end

  protected ####################################################################

    def handle_controller_error(error)
      puts "Request Error: #{error}" 
      error = Matterhorn::ResourceError.new(error)
      render error.to_response_options
    end
  end
end
