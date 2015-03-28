module AuthenticationHelpers
  extend ActiveSupport::Concern

  included do 

    STUB_TOKEN = "authenticate"
    let!(:current_user)  { User.make! auth_token: STUB_TOKEN }
    request_params.merge! auth_token: STUB_TOKEN

  end 
end
