module AuthenticatedSystem
  protected
    # Returns true or false if the abitant is logged in.
    # Preloads @current_abitant with the abitant model if they're logged in.
    def logged_in?
      !!current_abitant
    end

    # Accesses the current abitant from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_abitant
      @current_abitant ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_abitant == false
    end

    # Store the given abitant id in the session.
    def current_abitant=(new_abitant)
      session[:abitant_id] = new_abitant ? new_abitant.id : nil
      @current_abitant = new_abitant || false
    end

    # Check if the abitant is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the abitant
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_abitant.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the abitant is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
        format.any do
          head 401
          #request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_abitant and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_abitant, :logged_in?
    end

    # Called from #current_abitant.  First attempt to login by the abitant id stored in the session.
    def login_from_session
      self.current_abitant = Abitant.find_by_id(session[:abitant_id]) if session[:abitant_id]
    end

    # Called from #current_abitant.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_abitant = Abitant.authenticate(username, password)
      end
    end

    # Called from #current_abitant.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      abitant = cookies[:auth_token] && Abitant.find_by_remember_token(cookies[:auth_token])
      if abitant && abitant.remember_token?
        cookies[:auth_token] = { :value => abitant.remember_token, :expires => abitant.remember_token_expires_at }
        self.current_abitant = abitant
      end
    end
end
