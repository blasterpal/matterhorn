module ApiSpec
  extend ActiveSupport::Concern
  include SerialSpec
  include Matterhorn::SpecHelpers::Resourceful::ResourceHelpers

  def app
    Rails.application
  end
end