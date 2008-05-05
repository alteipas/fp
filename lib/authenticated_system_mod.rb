module AuthenticatedSystemMod
  #include AuthenticatedSystem
  def access_denied
    respond_to do |format|
      format.html do
        store_location
        redirect_to '/login'
      end
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end
end

