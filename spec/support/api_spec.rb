module ApiSpec
  extend ActiveSupport::Concern
  include SerialSpec

  def app
    Rails.application
  end
end