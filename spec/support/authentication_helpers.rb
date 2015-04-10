module AuthenticationHelpers
  extend ActiveSupport::Concern
  STUB_TOKEN = "authenticate"

  included do

    let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
    request_params.merge! auth_token: STUB_TOKEN

  end
end
