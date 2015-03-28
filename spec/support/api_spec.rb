require "resource_helpers"

module ApiSpec
  extend ActiveSupport::Concern
  include SerialSpec
  include ResourceHelpers

  STUB_TOKEN = "authenticate"


  def app
    Rails.application
  end
end
