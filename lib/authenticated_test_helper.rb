module AuthenticatedTestHelper
  # Sets the current inhabitant in the session from the inhabitant fixtures.
  def login_as(inhabitant)
    #@request.session[:inhabitant_id] = inhabitant ? inhabitants(inhabitant).id : nil
    @request.session[:inhabitant_id] = inhabitant ? Inhabitant.find(inhabitant).id : nil
  end


  def authorize_as(inhabitant)
    #@request.env["HTTP_AUTHORIZATION"] = inhabitant ? ActionController::HttpAuthentication::Basic.encode_credentials(inhabitants(inhabitant).login, 'test') : nil
    @request.env["HTTP_AUTHORIZATION"] = inhabitant ? ActionController::HttpAuthentication::Basic.encode_credentials(Inhabitant.find(inhabitant).login, 'pass') : nil
  end
end
