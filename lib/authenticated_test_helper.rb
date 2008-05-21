module AuthenticatedTestHelper
  # Sets the current abitant in the session from the abitant fixtures.
  def login_as(abitant)
    #@request.session[:abitant_id] = abitant ? abitants(abitant).id : nil
    @request.session[:abitant_id] = abitant ? Abitant.find(abitant).id : nil
  end


  def authorize_as(abitant)
    #@request.env["HTTP_AUTHORIZATION"] = abitant ? ActionController::HttpAuthentication::Basic.encode_credentials(abitants(abitant).login, 'test') : nil
    @request.env["HTTP_AUTHORIZATION"] = abitant ? ActionController::HttpAuthentication::Basic.encode_credentials(Abitant.find(abitant).login, 'pass') : nil
  end
end
