module AuthenticatedTestHelper
  # Sets the current fuser in the session from the fuser fixtures.
  def login_as(fuser)
    @request.session[:fuser_id] = fuser ? fusers(fuser).id : nil
  end

  def authorize_as(fuser)
    @request.env["HTTP_AUTHORIZATION"] = fuser ? ActionController::HttpAuthentication::Basic.encode_credentials(fusers(fuser).login, 'test') : nil
  end
end
