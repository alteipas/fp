module AuthenticatedSystem
  protected
    # Returns true or false if the inhabitant is logged in.
    # Preloads @current_inhabitant with the inhabitant model if they're logged in.
    def logged_in?
      !!current_inhabitant
    end

    # Accesses the current inhabitant from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_inhabitant
      @current_inhabitant ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_inhabitant == false
    end

    # Store the given inhabitant id in the session.
    def current_inhabitant=(new_inhabitant)
      session[:inhabitant_id] = new_inhabitant ? new_inhabitant.id : nil
      @current_inhabitant = new_inhabitant || false
    end

    # Check if the inhabitant is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the inhabitant
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_inhabitant.login != "bob"
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
    # behavior in case the inhabitant is not authorized
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

    # Inclusion hook to make #current_inhabitant and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_inhabitant, :logged_in?
    end

    # Called from #current_inhabitant.  First attempt to login by the inhabitant id stored in the session.
    def login_from_session
      self.current_inhabitant = Inhabitant.find_by_id(session[:inhabitant_id]) if session[:inhabitant_id]
    end

    # Called from #current_inhabitant.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_inhabitant = Inhabitant.authenticate(username, password)
      end
    end

    # Called from #current_inhabitant.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      inhabitant = cookies[:auth_token] && Inhabitant.find_by_remember_token(cookies[:auth_token])
      if inhabitant && inhabitant.remember_token?
        cookies[:auth_token] = { :value => inhabitant.remember_token, :expires => inhabitant.remember_token_expires_at }
        self.current_inhabitant = inhabitant
      end
    end
end
