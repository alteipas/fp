module AuthenticatedSystem
  protected
    # Returns true or false if the fuser is logged in.
    # Preloads @current_fuser with the fuser model if they're logged in.
    def logged_in?
      !!current_fuser
    end

    # Accesses the current fuser from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_fuser
      @current_fuser ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_fuser == false
    end

    # Store the given fuser id in the session.
    def current_fuser=(new_fuser)
      session[:fuser_id] = new_fuser ? new_fuser.id : nil
      @current_fuser = new_fuser || false
    end

    # Check if the fuser is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the fuser
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_fuser.login != "bob"
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
    # behavior in case the fuser is not authorized
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

    # Inclusion hook to make #current_fuser and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_fuser, :logged_in?
    end

    # Called from #current_fuser.  First attempt to login by the fuser id stored in the session.
    def login_from_session
      self.current_fuser = Fuser.find_by_id(session[:fuser_id]) if session[:fuser_id]
    end

    # Called from #current_fuser.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_fuser = Fuser.authenticate(username, password)
      end
    end

    # Called from #current_fuser.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      fuser = cookies[:auth_token] && Fuser.find_by_remember_token(cookies[:auth_token])
      if fuser && fuser.remember_token?
        cookies[:auth_token] = { :value => fuser.remember_token, :expires => fuser.remember_token_expires_at }
        self.current_fuser = fuser
      end
    end
end
