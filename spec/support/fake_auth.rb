module FakeAuth
  extend ActiveSupport::Concern
  ForbiddenError = Class.new(StandardError)

  included do

    before_filter :authenticate!

    helper_method :current_user
  end

protected #####

  def authenticate!
    current_user || raise(ForbiddenError)
  end

  def current_user
    User.where(auth_token: params[:auth_token]).first
  end

end
