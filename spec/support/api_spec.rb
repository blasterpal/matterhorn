require "resource_helpers"

module ApiSpec
  extend ActiveSupport::Concern
  include SerialSpec
  include ResourceHelpers

  def app
    Rails.application
  end
end
